import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { encryptService } from '../services/encryptService';

const prisma = new PrismaClient();

export const createCustomer = async (req: Request, res: Response) => {
  try {
    const { name, phone, address, gstin } = req.body;

    const encryptedName = await encryptService.encrypt(name);
    const encryptedPhone = await encryptService.encrypt(phone);
    const encryptedAddress = await encryptService.encrypt(address);

    const customer = await prisma.customer.create({
      data: {
        encryptedName,
        encryptedPhone,
        encryptedAddress,
        gstin,
      },
    });

    res.status(201).json({ message: 'Customer created', id: customer.id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const createOrder = async (req: Request, res: Response) => {
  try {
    const { customerId, totalAmount, inventoryItems } = req.body;
    // inventoryItems: [{ id, quantity }]

    const encryptedTotal = await encryptService.encrypt(totalAmount.toString());

    await prisma.$transaction(async (tx) => {
      const order = await tx.salesOrder.create({
        data: {
          customerId,
          status: 'PENDING',
          encryptedTotal,
        },
      });

      // Deduct from Finished Goods Inventory
      for (const item of inventoryItems) {
        await tx.inventoryItem.update({
          where: { id: item.id },
          data: { currentStock: { decrement: item.quantity } },
        });

        await tx.stockLog.create({
          data: {
            inventoryItemId: item.id,
            changeAmount: -item.quantity,
            reason: `SALES_ORDER_${order.id}`,
          },
        });
      }
    });

    res.status(201).json({ message: 'Sales Order created and inventory reserved' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const dispatchOrder = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { vehicleNumber, driverName } = req.body;

    await prisma.$transaction(async (tx) => {
      await tx.salesOrder.update({
        where: { id },
        data: { status: 'DISPATCHED' },
      });

      await tx.dispatchLog.create({
        data: {
          salesOrderId: id,
          vehicleNumber,
          driverName,
        },
      });
    });

    res.json({ message: 'Order dispatched successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const getOrders = async (req: Request, res: Response) => {
  try {
    const orders = await prisma.salesOrder.findMany({
      include: { customer: true, dispatchLogs: true }
    });

    const decrypted = await Promise.all(orders.map(async (o) => {
      const total = await encryptService.decrypt(o.encryptedTotal);
      return {
        ...o,
        totalAmount: parseFloat(total || '0'),
        encryptedTotal: undefined,
      };
    }));

    res.json(decrypted);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};
