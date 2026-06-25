import { Request, Response } from 'express';
import { PrismaClient, StageEnum } from '@prisma/client';
import { encryptService } from '../services/encryptService';

const prisma = new PrismaClient();

export const createLot = async (req: Request, res: Response) => {
  try {
    const { lotNumber, initialWeight, rcnInventoryId } = req.body;

    await prisma.$transaction(async (tx) => {
      // 1. Create the Lot
      const lot = await tx.processingLot.create({
        data: {
          lotNumber: lotNumber || `LOT-${Date.now()}`,
          initialWeight,
          currentStage: 'CLEANING',
        },
      });

      if (rcnInventoryId) {
        // 2. Deduct RCN Inventory
        await tx.inventoryItem.update({
          where: { id: rcnInventoryId },
          data: {
            currentStock: { decrement: initialWeight },
          },
        });

        // 3. Log stock movement
        await tx.stockLog.create({
          data: {
            inventoryItemId: rcnInventoryId,
            changeAmount: -initialWeight,
            reason: `LOT_CREATED_${lot.id}`,
          },
        });
      }
    });

    res.status(201).json({ message: 'Lot created and RCN deducted' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const getLots = async (req: Request, res: Response) => {
  try {
    const lots = await prisma.processingLot.findMany({
      include: { stageLogs: true },
    });
    res.json(lots);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const completeStage = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { stageName, startTime, endTime, inputWeight, outputWeight, wastageWeight, nextStage } = req.body;

    // Encrypt the proprietary yield metrics
    const encryptedOutput = await encryptService.encrypt(outputWeight.toString());
    const encryptedWastage = await encryptService.encrypt(wastageWeight.toString());

    await prisma.$transaction(async (tx) => {
      // 1. Log the completed stage
      await tx.stageLog.create({
        data: {
          lotId: id,
          stageName,
          startTime: new Date(startTime),
          endTime: new Date(endTime),
          inputWeight,
          encryptedOutput,
          encryptedWastage,
        },
      });

      // 2. Advance the lot to the next stage
      await tx.processingLot.update({
        where: { id },
        data: { currentStage: nextStage },
      });
    });

    res.json({ message: `Stage ${stageName} completed securely.` });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};
