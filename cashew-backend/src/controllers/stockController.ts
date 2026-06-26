import { Request, Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { prisma } from '../lib/prisma';
const getFactoryId = (req: Request) => req.headers['x-factory-id'] as string | undefined;


// ============================================================
// RAW STOCK
// ============================================================

export const getRawStock = async (req: Request, res: Response) => {
  try {
    const stocks = await prisma.rawStock.findMany({ where: { factoryId: getFactoryId(req) },
      orderBy: { date: 'desc' },
      include: { sortings: { select: { id: true, totalWeight: true } } },
    });

    const totalRaw = stocks.reduce((sum, s) => sum + s.weight, 0);
    const totalUsed = stocks.reduce((sum, s) => sum + s.usedWeight, 0);

    res.json({ stocks, totalRaw, totalUsed, available: totalRaw - totalUsed });
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

export const getRawStockDetail = async (req: Request, res: Response) => {
  try {
    const id = req.params.id as string;
    const stock = await prisma.rawStock.findUnique({
      where: { factoryId: getFactoryId(req), id },
      include: {
        sortings: {
          include: {
            lots: {
              include: {
                steps: { orderBy: { completedAt: 'asc' } },
                finishedStock: true
              }
            }
          }
        }
      }
    });
    if (!stock) return res.status(404).json({ error: 'Not found' });
    res.json(stock);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

export const addRawStock = async (req: Request, res: Response) => {
  try {
    const authReq = req as AuthRequest;
    if (authReq.userRole !== 'OWNER') {
      return res.status(403).json({ error: 'Only owners can add raw stock' });
    }

    const { weight, name, note, date } = req.body;
    if (!weight || weight <= 0) {
      return res.status(400).json({ error: 'Weight is required and must be > 0' });
    }

    const stock = await prisma.rawStock.create({
      data: { factoryId: getFactoryId(req), weight, name: name || 'Un-named Batch', note: note || null, date: date ? new Date(date) : new Date() },
    });

    await prisma.activityLog.create({
      data: { factoryId: getFactoryId(req), action: 'STOCK_ADDED', detail: `Added ${weight} kg raw cashew`, weight },
    });

    res.status(201).json(stock);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

export const deleteRawStock = async (req: Request, res: Response) => {
  try {
    const authReq = req as AuthRequest;
    if (authReq.userRole !== 'OWNER') {
      return res.status(403).json({ error: 'Only owners can delete raw stock' });
    }

    const id = req.params.id as string;
    const stock = await prisma.rawStock.findUnique({ where: { factoryId: getFactoryId(req), id }, include: { sortings: true } });
    if (!stock) return res.status(404).json({ error: 'Not found' });
    if ((stock as any).sortings.length > 0) return res.status(400).json({ error: 'Cannot delete — already used in sorting' });

    await prisma.rawStock.delete({ where: { id } });
    await prisma.activityLog.create({
      data: { factoryId: getFactoryId(req), action: 'STOCK_DELETED', detail: `Removed ${stock.weight} kg raw cashew entry`, weight: stock.weight },
    });
    res.json({ success: true });
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

export const mergeRawStock = async (req: AuthRequest, res: Response) => {
  try {
    const { rawStockIds, name } = req.body;
    const factoryId = getFactoryId(req) as string;

    if (!rawStockIds || !Array.isArray(rawStockIds) || rawStockIds.length < 2) {
      return res.status(400).json({ error: 'At least two raw stock IDs are required' });
    }

    const rawStocks = await prisma.rawStock.findMany({
      where: {
        id: { in: rawStockIds },
        factoryId,
      },
    });

    if (rawStocks.length !== rawStockIds.length) {
      return res.status(404).json({ error: 'Some raw stocks not found or do not belong to this factory' });
    }

    let totalAvailableWeight = 0;
    const noteLines: string[] = [];
    
    for (const stock of rawStocks) {
      const available = stock.weight - stock.usedWeight;
      if (available <= 0) {
        return res.status(400).json({ error: `Raw stock ${stock.name} has no available weight to merge` });
      }
      totalAvailableWeight += available;
      noteLines.push(`- ${stock.name}: ${available}kg`);
    }

    const merged = await prisma.$transaction(async (tx) => {
      // 1. Create the new merged raw stock
      const newStock = await tx.rawStock.create({
        data: {
          name: name || 'Merged Stock',
          weight: totalAvailableWeight,
          usedWeight: 0,
          note: `Merged from:\n${noteLines.join('\n')}`,
          factoryId,
        },
      });

      // 2. Reduce the weights of original raw stocks
      for (const stock of rawStocks) {
        const available = stock.weight - stock.usedWeight;
        const newWeight = stock.weight - available; // Reduces it to only what was used

        if (newWeight === 0 && stock.usedWeight === 0) {
          await tx.rawStock.delete({ where: { id: stock.id } });
        } else {
          await tx.rawStock.update({
            where: { id: stock.id },
            data: { weight: newWeight },
          });
        }
      }

      await tx.activityLog.create({
        data: {
          factoryId,
          action: 'MERGED_RAW_STOCK',
          detail: `Merged ${rawStocks.length} batches into ${newStock.name} (${totalAvailableWeight}kg)`,
          weight: totalAvailableWeight,
        },
      });

      return newStock;
    });

    res.status(201).json(merged);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

// ============================================================
// SORTING
// ============================================================

export const getSortings = async (req: Request, res: Response) => {
  try {
    const sortings = await prisma.sorting.findMany({ where: { factoryId: getFactoryId(req) },
      orderBy: { date: 'desc' },
      include: {
        rawStock: { select: { id: true, name: true, weight: true, date: true } },
        rawStocks: { include: { rawStock: { select: { id: true, name: true } } } },
        lots: { select: { id: true, name: true, category: true, initialWeight: true, status: true, currentStage: true } },
      },
    });
    res.json(sortings);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

export const createSorting = async (req: Request, res: Response) => {
  try {
    console.log('CREATE SORTING BODY:', req.body);
    const { rawStockId, rawStocks, totalWeight, lots, note } = req.body;
    if (!totalWeight || !lots || !Array.isArray(lots) || lots.length === 0) {
      console.log('Validation failed 1');
      return res.status(400).json({ error: 'totalWeight, and lots[] are required' });
    }

    // Support both old rawStockId format and new rawStocks array format
    let stocksToProcess: { id: string, weight: number }[] = [];
    if (rawStocks && Array.isArray(rawStocks)) {
      stocksToProcess = rawStocks;
    } else if (rawStockId) {
      stocksToProcess = [{ id: rawStockId, weight: totalWeight }];
    } else {
      return res.status(400).json({ error: 'rawStocks array is required' });
    }

    // Validate all raw stocks have enough available
    const factoryId = getFactoryId(req);
    for (const stock of stocksToProcess) {
      const rs = await prisma.rawStock.findUnique({ where: { factoryId, id: stock.id } });
      if (!rs) return res.status(404).json({ error: `Raw stock ${stock.id} not found` });
      const available = rs.weight - rs.usedWeight;
      if (stock.weight > available + 0.01) {
        return res.status(400).json({ error: `Only ${available.toFixed(1)} kg available in ${rs.name}, you asked for ${stock.weight} kg` });
      }
    }

    // Validate lot weights sum to totalWeight
    const lotWeightSum = lots.reduce((sum: number, l: any) => sum + (l.weight || 0), 0);
    if (Math.abs(lotWeightSum - totalWeight) > 0.5) {
      return res.status(400).json({ error: `Lot weights (${lotWeightSum} kg) must equal total sorting weight (${totalWeight} kg)` });
    }

    // Create sorting + lots in a transaction
    const sorting = await prisma.$transaction(async (tx) => {
      const s = await tx.sorting.create({
        data: {
          rawStockId: stocksToProcess.length === 1 ? stocksToProcess[0].id : null,
          totalWeight,
          note: note || null,
          factoryId,
        },
      });

      // Create SortingRawStock links and update RawStock usedWeight
      for (const stock of stocksToProcess) {
        await tx.sortingRawStock.create({
          data: {
            sortingId: s.id,
            rawStockId: stock.id,
            weight: stock.weight,
          }
        });

        const rs = await tx.rawStock.findUnique({ where: { id: stock.id } });
        if (rs) {
          await tx.rawStock.update({
            where: { id: stock.id },
            data: { usedWeight: rs.usedWeight + stock.weight },
          });
        }
      }

      for (const lot of lots) {
        await tx.lot.create({
          data: {
            sortingId: s.id,
            name: lot.name || `Lot ${lot.category}`,
            category: lot.category || 'General',
            initialWeight: lot.weight,
            currentWeight: lot.weight,
            note: lot.note || null,
            factoryId,
          },
        });
      }

      return s;
    });

    await prisma.activityLog.create({
      data: { factoryId,
        action: 'SORTING_DONE',
        detail: `Sorted ${totalWeight} kg into ${lots.length} lots`,
        weight: totalWeight,
      },
    });

    const finalSorting = await prisma.sorting.findUnique({
      where: { id: sorting.id },
      include: {
        lots: true,
        rawStock: true,
        rawStocks: { include: { rawStock: true } }
      }
    });

    res.status(201).json(finalSorting);
  } catch (e: any) {
    console.error('CREATE SORTING ERROR:', e);
    res.status(500).json({ error: e.message });
  }
};

// ============================================================
// LOTS & PROCESSING
// ============================================================

export const getLots = async (req: Request, res: Response) => {
  try {
    const status = (req.query.status as string) || 'ALL';
    const where: any = { factoryId: getFactoryId(req) };
    if (status !== 'ALL') where.status = status;

    const lots = await prisma.lot.findMany({
      where,
      orderBy: { updatedAt: 'desc' },
      include: {
        steps: { orderBy: { completedAt: 'asc' } },
        finishedStock: true,
        sorting: { include: { rawStock: { select: { name: true } }, rawStocks: { include: { rawStock: { select: { name: true } } } } } },
      },
    });
    res.json(lots);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

export const getLotDetail = async (req: Request, res: Response) => {
  try {
    const id = req.params.id as string;
    const lot = await prisma.lot.findUnique({
      where: { factoryId: getFactoryId(req), id },
      include: {
        steps: { orderBy: { completedAt: 'asc' } },
        finishedStock: { include: { dispatches: { orderBy: { date: 'desc' } } } },
        sorting: { 
          include: { 
            rawStock: { select: { id: true, name: true, weight: true, date: true } },
            rawStocks: { include: { rawStock: { select: { id: true, name: true } } } }
          } 
        },
      },
    });
    if (!lot) return res.status(404).json({ error: 'Lot not found' });
    res.json(lot);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

const STAGES = ['CLEANING', 'BOILING', 'COOLING', 'SHELLING', 'DRYING', 'PEELING', 'GRADING', 'PACKING'];

export const startLot = async (req: Request, res: Response) => {
  try {
    const lotId = req.params.id as string;
    const { customWeight, note } = req.body || {};

    const lot = await prisma.lot.findUnique({ where: { factoryId: getFactoryId(req), id: lotId } });
    if (!lot) return res.status(404).json({ error: 'Lot not found' });
    if (lot.status !== 'PENDING') return res.status(400).json({ error: 'Lot already started' });

    const finalWeight = customWeight && customWeight > 0 ? Number(customWeight) : lot.initialWeight;
    const combinedNote = note ? (lot.note ? `${lot.note}\nStarted with note: ${note}` : `Started with note: ${note}`) : lot.note;

    let remainingWeight = 0;
    if (finalWeight < lot.initialWeight) {
      remainingWeight = lot.initialWeight - finalWeight;
    }

    const updated = await prisma.$transaction(async (tx) => {
      if (remainingWeight > 0) {
        await tx.lot.create({
          data: {
            sortingId: lot.sortingId,
            name: `${lot.name} (Remaining)`,
            category: lot.category,
            initialWeight: remainingWeight,
            currentWeight: remainingWeight,
            status: 'PENDING',
            note: `Split from ${lot.name}. Remaining unstarted weight.`,
            factoryId: getFactoryId(req),
          }
        });
      }

      return tx.lot.update({
        where: { id: lot.id },
        data: { 
          status: 'PROCESSING', 
          currentStage: 'CLEANING',
          initialWeight: finalWeight,
          currentWeight: finalWeight,
          note: combinedNote,
        },
      });
    });

    await prisma.activityLog.create({
      data: { factoryId: getFactoryId(req), action: 'LOT_STARTED', detail: `Started processing lot "${lot.name}" (${finalWeight} kg) ${remainingWeight > 0 ? '(Split ' + remainingWeight + 'kg pending)' : ''} ${note ? '- ' + note : ''}`, weight: finalWeight },
    });

    res.json(updated);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

export const completeStage = async (req: Request, res: Response) => {
  try {
    const { outputWeight, note, completedBy, sortingMethod } = req.body;
    const lotId = req.params.id as string;
    const lot = await prisma.lot.findUnique({ where: { factoryId: getFactoryId(req), id: lotId } });
    if (!lot) return res.status(404).json({ error: 'Lot not found' });
    if (lot.status !== 'PROCESSING') return res.status(400).json({ error: 'Lot is not in processing' });
    if (!outputWeight || outputWeight <= 0) return res.status(400).json({ error: 'Output weight is required' });

    const currentStage = lot.currentStage;
    const inputWeight = lot.currentWeight;
    const wastage = inputWeight - outputWeight;

    // Save step
    await prisma.processingStep.create({
      data: { factoryId: getFactoryId(req),
        lotId: lot.id,
        stageName: currentStage,
        inputWeight,
        outputWeight,
        wastage,
        note: note || null,
        completedBy: completedBy || null,
        sortingMethod: sortingMethod || null,
      },
    });

    // Determine next stage
    const currentIdx = STAGES.indexOf(currentStage);
    const isLastStage = currentIdx >= STAGES.length - 1;

    if (isLastStage) {
      // Packing done → move to finished stock
      await prisma.lot.update({
        where: { id: lot.id },
        data: { status: 'COMPLETED', currentWeight: outputWeight, currentStage: 'COMPLETED' },
      });

      await prisma.finishedStock.create({
        data: { factoryId: getFactoryId(req), lotId: lot.id, packedWeight: outputWeight, note: note || null },
      });

      await prisma.activityLog.create({
        data: { factoryId: getFactoryId(req), action: 'LOT_COMPLETED', detail: `Lot "${lot.name}" completed. Packed: ${outputWeight} kg`, weight: outputWeight },
      });
    } else {
      // Move to next stage
      const nextStage = STAGES[currentIdx + 1];
      await prisma.lot.update({
        where: { id: lot.id },
        data: { currentWeight: outputWeight, currentStage: nextStage },
      });

      await prisma.activityLog.create({
        data: { factoryId: getFactoryId(req), action: 'STAGE_COMPLETED', detail: `Lot "${lot.name}": ${currentStage} done → ${nextStage}. Output: ${outputWeight} kg`, weight: outputWeight },
      });
    }

    // Return updated lot
    const updated = await prisma.lot.findUnique({
      where: { factoryId: getFactoryId(req), id: lot.id },
      include: { steps: { orderBy: { completedAt: 'asc' } }, finishedStock: true },
    });

    res.json(updated);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

// ============================================================
// FINISHED STOCK
// ============================================================

export const getFinishedStock = async (req: Request, res: Response) => {
  try {
    const stocks = await prisma.finishedStock.findMany({ where: { factoryId: getFactoryId(req) },
      orderBy: { completedAt: 'desc' },
      include: {
        lot: { select: { id: true, name: true, category: true, initialWeight: true, sorting: { select: { date: true, rawStock: { select: { name: true, date: true } } } } } },
        dispatches: { orderBy: { date: 'desc' } },
      },
    });

    const totalPacked = stocks.reduce((s, f) => s + f.packedWeight, 0);
    const totalDispatched = stocks.reduce((s, f) => s + f.dispatched, 0);

    res.json({ stocks, totalPacked, totalDispatched, available: totalPacked - totalDispatched });
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

export const dispatchStock = async (req: Request, res: Response) => {
  try {
    const { weight, note } = req.body;
    const id = req.params.id as string;
    if (!weight || weight <= 0) return res.status(400).json({ error: 'Dispatch weight is required' });

    const fs = await prisma.finishedStock.findUnique({ where: { factoryId: getFactoryId(req), id } });
    if (!fs) return res.status(404).json({ error: 'Finished stock not found' });

    const availableWeight = fs.packedWeight - fs.dispatched;
    if (weight > availableWeight + 0.01) {
      return res.status(400).json({ error: `Only ${availableWeight.toFixed(1)} kg available for dispatch` });
    }

    await prisma.$transaction(async (tx: any) => {
      await tx.dispatch.create({ data: { finishedStockId: id, weight, note: note || null } });
      await tx.finishedStock.update({ where: { id }, data: { dispatched: (fs as any).dispatched + weight } });
    });

    await prisma.activityLog.create({
      data: { factoryId: getFactoryId(req), action: 'STOCK_DISPATCHED', detail: `Dispatched ${weight} kg finished cashew`, weight },
    });

    res.json({ success: true });
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

// ============================================================
// DASHBOARD SUMMARY
// ============================================================

export const getDashboard = async (req: Request, res: Response) => {
  try {
    const factoryId = getFactoryId(req);

    // Raw stock
    const rawStocks = await prisma.rawStock.findMany({ where: { factoryId } });
    const totalRaw = rawStocks.reduce((s, r) => s + r.weight, 0);
    const totalUsed = rawStocks.reduce((s, r) => s + r.usedWeight, 0);

    // Lots
    const allLots = await prisma.lot.findMany({ where: { factoryId } });
    const processingLots = allLots.filter(l => l.status === 'PROCESSING');
    const completedLots = allLots.filter(l => l.status === 'COMPLETED');
    const pendingLots = allLots.filter(l => l.status === 'PENDING');

    // Finished stock
    const finishedStocks = await prisma.finishedStock.findMany({ where: { factoryId } });
    const totalPacked = finishedStocks.reduce((s, f) => s + f.packedWeight, 0);
    const totalDispatched = finishedStocks.reduce((s, f) => s + f.dispatched, 0);

    // Recent activity
    const recentActivity = await prisma.activityLog.findMany({ where: { factoryId },
      orderBy: { timestamp: 'desc' },
      take: 15,
    });

    res.json({
      rawStock: { total: totalRaw, used: totalUsed, available: totalRaw - totalUsed },
      processing: {
        pending: pendingLots.length,
        active: processingLots.length,
        completed: completedLots.length,
        totalLots: allLots.length,
        activeWeight: processingLots.reduce((s, l) => s + l.currentWeight, 0),
      },
      finished: { totalPacked, totalDispatched, available: totalPacked - totalDispatched },
      recentActivity,
    });
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

// ============================================================
// WASTAGE
// ============================================================

export const getWastage = async (req: Request, res: Response) => {
  try {
    const steps = await prisma.processingStep.findMany({
      where: { factoryId: getFactoryId(req), wastage: { gt: 0 } },
      orderBy: { completedAt: 'desc' },
      include: {
        lot: { select: { name: true, category: true, sorting: { select: { rawStock: { select: { name: true, date: true } } } } } }
      }
    });

    const totalWastage = steps.reduce((sum, s) => sum + s.wastage, 0);

    res.json({
      totalWastage,
      history: steps.map(s => ({
        id: s.id,
        lotName: s.lot.name,
        category: s.lot.category,
        stageName: s.stageName,
        wastage: s.wastage,
        date: s.completedAt,
        rawStockName: s.lot.sorting?.rawStock?.name ?? 'Unknown',
        rawStockDate: s.lot.sorting?.rawStock?.date,
        note: s.note
      }))
    });
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

// ============================================================
// EDITS AND DELETES (MISTAKE CORRECTIONS)
// ============================================================

export const deleteProcessingStep = async (req: Request, res: Response) => {
  try {
    const id = req.params.id as string;
    const step = await prisma.processingStep.findUnique({ where: { id, factoryId: getFactoryId(req) } });
    if (!step) return res.status(404).json({ error: 'Step not found' });
    
    const lot = await prisma.lot.findUnique({ where: { id: step.lotId } });
    if (!lot) return res.status(404).json({ error: 'Lot not found' });

    // Find previous stage
    const STAGES = ['CLEANING', 'BOILING', 'COOLING', 'SHELLING', 'DRYING', 'PEELING', 'GRADING', 'PACKING'];
    const currentIdx = STAGES.indexOf(step.stageName);
    const previousStage = currentIdx > 0 ? STAGES[currentIdx - 1] : STAGES[0];
    const isLastStage = currentIdx >= STAGES.length - 1;

    await prisma.$transaction(async (tx) => {
      // Delete the step
      await tx.processingStep.delete({ where: { id } });

      // If it was the final stage, also delete FinishedStock
      if (isLastStage) {
        await tx.finishedStock.deleteMany({ where: { lotId: lot.id } });
      }

      // Revert Lot State
      await tx.lot.update({
        where: { id: lot.id },
        data: {
          currentWeight: step.inputWeight,
          currentStage: previousStage,
          status: 'PROCESSING', // Ensure it's processing if it was completed
        }
      });

      await tx.activityLog.create({
        data: { factoryId: getFactoryId(req)!, action: 'STEP_DELETED', detail: `Reverted step ${step.stageName} for lot ${lot.name}. Reverted weight to ${step.inputWeight} kg`, weight: step.outputWeight },
      });
    });

    res.json({ success: true });
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

export const editLot = async (req: Request, res: Response) => {
  try {
    const id = req.params.id as string;
    const { name, currentWeight, status, note } = req.body;
    const updated = await prisma.lot.update({
      where: { id, factoryId: getFactoryId(req) },
      data: { name, currentWeight, status, note },
    });
    res.json(updated);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

export const editRawStock = async (req: Request, res: Response) => {
  try {
    const id = req.params.id as string;
    const { name, weight, note } = req.body;
    const updated = await prisma.rawStock.update({
      where: { id, factoryId: getFactoryId(req) },
      data: { name, weight, note },
    });
    res.json(updated);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

// ============================================================
// REVERT & ADD STEP (LOT MANAGEMENT)
// ============================================================

export const revertToStage = async (req: AuthRequest, res: Response) => {
  const lotId = req.params.id as string;
  const { targetStage } = req.body; // e.g. 'CLEANING'

  const lot = await prisma.lot.findUnique({ where: { id: lotId }, include: { steps: true } });
  if (!lot) return res.status(404).json({ error: 'Lot not found' });
  if (lot.status !== 'PROCESSING' && lot.status !== 'COMPLETED') return res.status(400).json({ error: 'Lot is not in processing or completed state' });

  const targetIdx = STAGES.indexOf(targetStage);
  if (targetIdx === -1) return res.status(400).json({ error: 'Invalid stage' });

  // Find the step for the target stage to get its inputWeight
  const targetStep = lot.steps.find(s => s.stageName === targetStage);
  const revertWeight = targetStep?.inputWeight ?? lot.initialWeight;

  // Delete all steps from targetStage onward
  const stagesToDelete = STAGES.slice(targetIdx);

  await prisma.$transaction(async (tx) => {
    // Delete processing steps for these stages
    await tx.processingStep.deleteMany({
      where: { lotId, stageName: { in: stagesToDelete } }
    });

    // If lot was COMPLETED, delete the FinishedStock too
    if (lot.status === 'COMPLETED') {
      await tx.finishedStock.deleteMany({ where: { lotId } });
    }

    // Revert lot state
    await tx.lot.update({
      where: { id: lotId },
      data: {
        currentStage: targetStage,
        currentWeight: revertWeight,
        status: 'PROCESSING',
      }
    });
  });

  const updated = await prisma.lot.findUnique({ where: { id: lotId }, include: { steps: true, finishedStock: true } });
  res.json(updated);
};

export const addStepRecord = async (req: AuthRequest, res: Response) => {
  const lotId = req.params.id as string;
  const { stageName, outputWeight, note, sortingMethod } = req.body;
  const factoryId = getFactoryId(req) as string;

  const lot = await prisma.lot.findUnique({ where: { id: lotId }, include: { steps: true } });
  if (!lot) return res.status(404).json({ error: 'Lot not found' });
  if (lot.status !== 'PROCESSING') return res.status(400).json({ error: 'Lot must be in PROCESSING state' });
  if (lot.currentStage !== stageName) return res.status(400).json({ error: `Lot is currently at ${lot.currentStage}, not ${stageName}` });

  const inputWeight = lot.currentWeight;
  const wastage = inputWeight - outputWeight;
  const stageIdx = STAGES.indexOf(stageName);
  const isLast = stageIdx === STAGES.length - 1; // PACKING

  const result = await prisma.$transaction(async (tx) => {
    const step = await tx.processingStep.create({
      data: {
        lotId,
        stageName,
        inputWeight,
        outputWeight,
        wastage: wastage > 0 ? wastage : 0,
        note,
        sortingMethod: stageName === 'GRADING' ? sortingMethod : undefined,
        factoryId,
      }
    });

    if (isLast) {
      await tx.lot.update({
        where: { id: lotId },
        data: { status: 'COMPLETED', currentWeight: outputWeight, currentStage: 'COMPLETED' }
      });
      await tx.finishedStock.create({
        data: { lotId, packedWeight: outputWeight, factoryId }
      });
    } else {
      const nextStage = STAGES[stageIdx + 1];
      await tx.lot.update({
        where: { id: lotId },
        data: { currentStage: nextStage, currentWeight: outputWeight }
      });
    }

    return step;
  });

  const updated = await prisma.lot.findUnique({ where: { id: lotId }, include: { steps: true, finishedStock: true } });
  res.json(updated);
};

export const unstartLot = async (req: AuthRequest, res: Response) => {
  const lotId = req.params.id as string;
  const lot = await prisma.lot.findUnique({ where: { factoryId: getFactoryId(req), id: lotId } });
  if (!lot) return res.status(404).json({ error: 'Lot not found' });
  if (lot.status !== 'PROCESSING') return res.status(400).json({ error: 'Lot must be in PROCESSING state to un-start' });

  await prisma.$transaction(async (tx) => {
    // Delete all processing steps for this lot
    await tx.processingStep.deleteMany({ where: { lotId } });
    
    // Revert lot back to PENDING and reset weight
    await tx.lot.update({
      where: { id: lotId },
      data: {
        status: 'PENDING',
        currentStage: 'PENDING',
        currentWeight: lot.initialWeight,
      }
    });
  });

  const updated = await prisma.lot.findUnique({ where: { id: lotId }, include: { steps: true, finishedStock: true } });
  res.json(updated);
};

export const revertSorting = async (req: AuthRequest, res: Response) => {
  const sortingId = req.params.id as string;
  const factoryId = getFactoryId(req) as string;

  const sorting = await prisma.sorting.findUnique({ 
    where: { factoryId, id: sortingId },
    include: { lots: true, rawStock: true, rawStocks: true }
  });
  if (!sorting) return res.status(404).json({ error: 'Sorting not found' });

  await prisma.$transaction(async (tx) => {
    // Delete all processing steps for all lots in this sorting
    const lotIds = sorting.lots.map(l => l.id);
    await tx.processingStep.deleteMany({ where: { lotId: { in: lotIds } } });
    
    // Delete all finished stock for all lots in this sorting
    await tx.finishedStock.deleteMany({ where: { lotId: { in: lotIds } } });

    // Delete all lots associated with this sorting
    await tx.lot.deleteMany({ where: { sortingId } });
    
    // Refund the weight back to the RawStocks
    for (const rsLink of sorting.rawStocks) {
      const rs = await tx.rawStock.findUnique({ where: { id: rsLink.rawStockId } });
      if (rs) {
        await tx.rawStock.update({
          where: { id: rsLink.rawStockId },
          data: { usedWeight: Math.max(0, rs.usedWeight - rsLink.weight) }
        });
      }
    }
    
    // Support backwards compatibility if it didn't use rawStocks array
    if (sorting.rawStocks.length === 0 && sorting.rawStock) {
      await tx.rawStock.update({
        where: { id: sorting.rawStockId! },
        data: { usedWeight: Math.max(0, sorting.rawStock.usedWeight - sorting.totalWeight) }
      });
    }
    
    // Delete the sorting record
    await tx.sorting.delete({ where: { id: sortingId } });
  });

  res.json({ message: 'Sorting forcefully reverted successfully' });
};

// ============================================================
// GLOBAL DASHBOARD & TRANSFER (CROSS-FACTORY)
// ============================================================

export const getGlobalDashboard = async (req: Request, res: Response) => {
  try {
    const rawStocks = await prisma.rawStock.findMany({ include: { factory: true } });
    const allLots = await prisma.lot.findMany({ include: { factory: true } });
    const finishedStocks = await prisma.finishedStock.findMany({ include: { factory: true } });
    const factories = await prisma.factory.findMany();

    const factoryMetrics = factories.map(f => {
      const fRaw = rawStocks.filter(r => r.factoryId === f.id);
      const fLots = allLots.filter(l => l.factoryId === f.id);
      const fFinished = finishedStocks.filter(s => s.factoryId === f.id);

      const totalRaw = fRaw.reduce((s, r) => s + r.weight, 0);
      const totalUsed = fRaw.reduce((s, r) => s + r.usedWeight, 0);
      const activeWeight = fLots.filter(l => l.status === 'PROCESSING').reduce((s, l) => s + l.currentWeight, 0);
      const totalPacked = fFinished.reduce((s, f) => s + f.packedWeight, 0);
      const totalDispatched = fFinished.reduce((s, f) => s + f.dispatched, 0);

      return {
        factoryId: f.id,
        factoryName: f.name,
        rawAvailable: totalRaw - totalUsed,
        processingWeight: activeWeight,
        finishedAvailable: totalPacked - totalDispatched,
      };
    });

    const globalTotalRawAvailable = factoryMetrics.reduce((s, m) => s + m.rawAvailable, 0);
    const globalTotalProcessing = factoryMetrics.reduce((s, m) => s + m.processingWeight, 0);
    const globalTotalFinished = factoryMetrics.reduce((s, m) => s + m.finishedAvailable, 0);

    res.json({
      global: {
        rawAvailable: globalTotalRawAvailable,
        processingWeight: globalTotalProcessing,
        finishedAvailable: globalTotalFinished,
      },
      factories: factoryMetrics,
    });
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

export const transferLot = async (req: Request, res: Response) => {
  try {
    const lotId = req.params.id as string;
    const { targetFactoryId } = req.body;
    if (!targetFactoryId) return res.status(400).json({ error: 'targetFactoryId is required' });

    const targetFactory = await prisma.factory.findUnique({ where: { id: targetFactoryId } });
    if (!targetFactory) return res.status(404).json({ error: 'Target factory not found' });

    const lot = await prisma.lot.findUnique({ where: { id: lotId }, include: { finishedStock: true } });
    if (!lot) return res.status(404).json({ error: 'Lot not found' });

    const oldFactoryId = lot.factoryId;
    const factoryId = getFactoryId(req) as string;
    if (oldFactoryId === targetFactoryId) {
      return res.status(400).json({ error: 'Lot is already in this factory' });
    }

    await prisma.$transaction(async (tx) => {
      await tx.lot.update({
        where: { id: lotId },
        data: { factoryId: targetFactoryId },
      });

      if (lot.finishedStock) {
        await tx.finishedStock.update({
          where: { id: lot.finishedStock.id },
          data: { factoryId: targetFactoryId },
        });
      }

      if (oldFactoryId) {
        await tx.activityLog.create({
          data: { factoryId: oldFactoryId, action: 'LOT_TRANSFERRED_OUT', detail: `Lot ${lot.name} transferred out`, weight: lot.currentWeight },
        });
      }
      await tx.activityLog.create({
        data: { factoryId: targetFactoryId, action: 'LOT_TRANSFERRED_IN', detail: `Lot ${lot.name} transferred in`, weight: lot.currentWeight },
      });

      await tx.processingStep.create({
        data: {
          lotId,
          stageName: 'TRANSFERRED',
          note: `Transferred to ${targetFactory.name}`,
          factoryId: factoryId // the source factory ID
        }
      });
    });

    res.json({ success: true, message: 'Lot transferred successfully' });
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};

export const transferRawStock = async (req: AuthRequest, res: Response) => {
  const id = req.params.id as string;
  const { targetFactoryId, weight } = req.body;
  const factoryId = getFactoryId(req) as string;

  if (targetFactoryId === factoryId) return res.status(400).json({ error: 'Cannot transfer to same factory' });

  const rawStock = await prisma.rawStock.findUnique({ where: { id, factoryId } });
  if (!rawStock) return res.status(404).json({ error: 'Raw stock not found' });

  const available = rawStock.weight - rawStock.usedWeight;
  if (weight <= 0 || weight > available) return res.status(400).json({ error: 'Invalid weight' });

  const sourceFactory = await prisma.factory.findUnique({ where: { id: factoryId } });
  const targetFactory = await prisma.factory.findUnique({ where: { id: targetFactoryId } });
  if (!sourceFactory || !targetFactory) return res.status(404).json({ error: 'Factory not found' });

  await prisma.$transaction(async (tx) => {
    // 1. Create the new record in the destination factory
    await tx.rawStock.create({
      data: {
        weight,
        usedWeight: 0,
        name: `${rawStock.name} (Transfer)`,
        note: rawStock.note,
        factoryId: targetFactoryId,
        originalRawStockId: id
      }
    });

    // 2. Reduce the weight from the source factory
    const newWeight = rawStock.weight - weight;
    if (newWeight === 0 && rawStock.usedWeight === 0) {
      // If nothing was sorted and we transferred everything, delete the empty husk
      await tx.rawStock.delete({ where: { id } });
    } else {
      // Otherwise, just update the total weight to reflect the stock left in this factory
      await tx.rawStock.update({
        where: { id },
        data: { weight: newWeight }
      });
    }

    // 3. Log the activities
    await tx.activityLog.create({
      data: { action: 'TRANSFERRED_RAW_STOCK', detail: `Transferred ${weight}kg of ${rawStock.name} to ${targetFactory.name}`, weight, factoryId }
    });
    await tx.activityLog.create({
      data: { action: 'RECEIVED_RAW_STOCK', detail: `Received ${weight}kg of ${rawStock.name} from ${sourceFactory.name}`, weight, factoryId: targetFactoryId }
    });
  });

  res.json({ message: 'Raw stock transferred successfully' });
};

export const transferFinishedStock = async (req: Request, res: Response) => {
  try {
    const finishedStockId = req.params.id as string;
    const { targetFactoryId } = req.body;
    
    if (!targetFactoryId) {
      return res.status(400).json({ error: 'targetFactoryId is required' });
    }

    const sourceFactoryId = getFactoryId(req);
    if (!sourceFactoryId) return res.status(400).json({ error: 'Source factory ID missing in headers' });

    if (sourceFactoryId === targetFactoryId) {
      return res.status(400).json({ error: 'Cannot transfer to the same factory' });
    }

    const finishedStock = await prisma.finishedStock.findUnique({ 
      where: { id: finishedStockId },
      include: { lot: true } 
    });

    if (!finishedStock) return res.status(404).json({ error: 'Finished stock not found' });
    if (finishedStock.factoryId !== sourceFactoryId) {
      return res.status(403).json({ error: 'Finished stock does not belong to your factory' });
    }

    const sourceFactory = await prisma.factory.findUnique({ where: { id: sourceFactoryId } });
    const targetFactory = await prisma.factory.findUnique({ where: { id: targetFactoryId } });

    if (!sourceFactory || !targetFactory) {
      return res.status(404).json({ error: 'Source or target factory not found' });
    }

    await prisma.$transaction(async (tx) => {
      await tx.finishedStock.update({
        where: { id: finishedStockId },
        data: { factoryId: targetFactoryId }
      });

      if (finishedStock.lot) {
        await tx.lot.update({
          where: { id: finishedStock.lot.id },
          data: { factoryId: targetFactoryId }
        });
      }

      await tx.activityLog.create({
        data: { factoryId: sourceFactoryId, action: 'TRANSFERRED_FINISHED_STOCK', detail: `Transferred finished stock to ${targetFactory.name}` }
      });

      await tx.activityLog.create({
        data: { factoryId: targetFactoryId, action: 'RECEIVED_FINISHED_STOCK', detail: `Received finished stock from ${sourceFactory.name}` }
      });
    });

    res.json({ success: true, message: 'Finished stock transferred successfully' });
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
};
