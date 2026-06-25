import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { encryptService } from '../services/encryptService';

const prisma = new PrismaClient();

export const submitGrading = async (req: Request, res: Response) => {
  try {
    const { lotId, w320Weight, w240Weight, splitsWeight, qcNotes, finishedGoodsInventoryIds } = req.body;

    // Encrypt the proprietary grading distributions
    const encryptedW320 = await encryptService.encrypt(w320Weight.toString());
    const encryptedW240 = await encryptService.encrypt(w240Weight.toString());
    const encryptedSplits = await encryptService.encrypt(splitsWeight.toString());

    await prisma.$transaction(async (tx) => {
      // 1. Create Grading Record
      await tx.gradingRecord.create({
        data: {
          lotId,
          encryptedW320,
          encryptedW240,
          encryptedSplits,
          qcNotes,
        },
      });

      // 2. Mark Lot as Completed
      await tx.processingLot.update({
        where: { id: lotId },
        data: { status: 'COMPLETED' },
      });

      // 3. Add finished goods to inventory (assuming IDs are passed in for W320, W240, Splits)
      if (finishedGoodsInventoryIds && finishedGoodsInventoryIds.w320) {
        await tx.inventoryItem.update({
          where: { id: finishedGoodsInventoryIds.w320 },
          data: { currentStock: { increment: w320Weight } },
        });
      }
      if (finishedGoodsInventoryIds && finishedGoodsInventoryIds.w240) {
        await tx.inventoryItem.update({
          where: { id: finishedGoodsInventoryIds.w240 },
          data: { currentStock: { increment: w240Weight } },
        });
      }
    });

    res.status(201).json({ message: 'Grading submitted, lot completed, and inventory updated' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};
