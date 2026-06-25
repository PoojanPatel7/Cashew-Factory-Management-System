import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { encryptService } from '../services/encryptService';

const prisma = new PrismaClient();

export const createPO = async (req: Request, res: Response) => {
  try {
    const { supplierId, itemType, quantity, pricePerUnit } = req.body;

    const encryptedPrice = await encryptService.encrypt(pricePerUnit.toString());

    const po = await prisma.purchaseOrder.create({
      data: {
        supplierId,
        itemType,
        quantity,
        encryptedPrice,
      },
    });

    res.status(201).json({ message: 'Purchase Order created', id: po.id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const receivePO = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { receivedQty, notes, inventoryItemId, status } = req.body;

    await prisma.$transaction(async (tx) => {
      // 1. Update PO Status
      await tx.purchaseOrder.update({
        where: { id },
        data: { status: status as string },
      });

      // 2. Create Goods Receipt
      await tx.goodsReceipt.create({
        data: {
          purchaseOrderId: id,
          receivedQty,
          notes,
        },
      });

      // 3. Update Inventory & Log
      await tx.inventoryItem.update({
        where: { id: inventoryItemId },
        data: { currentStock: { increment: receivedQty } },
      });

      await tx.stockLog.create({
        data: {
          inventoryItemId,
          changeAmount: receivedQty,
          reason: `PO_RECEIPT_${id}`,
        },
      });
    });

    res.json({ message: 'PO Received and Inventory Updated' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const getPOs = async (req: Request, res: Response) => {
  try {
    const pos = await prisma.purchaseOrder.findMany({
      include: {
        supplier: true,
      },
      orderBy: { createdAt: 'desc' },
    });
    
    // Decrypt prices and map to what Flutter UI expects
    const decryptedPOs = await Promise.all(pos.map(async (po) => {
      const price = parseFloat(await encryptService.decrypt(po.encryptedPrice));
      const amount = (po.quantity * price).toFixed(2);
      const supplierName = po.supplier ? await encryptService.decrypt(po.supplier.encryptedName) : 'Unknown';
      
      return {
        id: po.id,
        supplier: supplierName,
        date: po.createdAt.toISOString().split('T')[0], // YYYY-MM-DD
        qty: `${po.quantity} MT`,
        amount: `₹${amount}`,
        status: po.status === 'PENDING' ? 'Draft' : po.status,
      };
    }));
    
    res.json(decryptedPOs);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};
