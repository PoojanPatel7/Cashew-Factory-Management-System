import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getInventory = async (req: Request, res: Response) => {
  try {
    const { lowStock } = req.query;
    let items;

    if (lowStock === 'true') {
      items = await prisma.$queryRaw`SELECT * FROM "InventoryItem" WHERE "currentStock" <= "minThreshold"`;
    } else {
      items = await prisma.inventoryItem.findMany();
    }

    res.json(items);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const adjustStock = async (req: Request, res: Response) => {
  try {
    const { inventoryItemId, changeAmount, reason } = req.body;

    // Run in a transaction to ensure log is created and stock is updated atomically
    await prisma.$transaction(async (tx) => {
      await tx.inventoryItem.update({
        where: { id: inventoryItemId },
        data: { currentStock: { increment: changeAmount } },
      });

      await tx.stockLog.create({
        data: {
          inventoryItemId,
          changeAmount,
          reason,
        },
      });
    });

    res.json({ message: 'Stock adjusted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};
