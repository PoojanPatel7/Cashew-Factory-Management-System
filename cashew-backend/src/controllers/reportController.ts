import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { encryptService } from '../services/encryptService';

const prisma = new PrismaClient();

export const getFinancialPnL = async (req: Request, res: Response) => {
  try {
    // To calculate PnL securely, we must fetch encrypted transactions, 
    // decrypt them in memory using the Encrypt Engine, and aggregate the total.
    
    // Fetch all REVENUE and EXPENSE ledger accounts
    const ledgers = await prisma.ledgerAccount.findMany({
      where: {
        type: { in: ['REVENUE', 'EXPENSE'] }
      }
    });

    let totalRevenue = 0;
    let totalExpense = 0;

    for (const ledger of ledgers) {
      // Decrypt the balance
      const decryptedBalanceStr = await encryptService.decrypt(ledger.encryptedBalance);
      const balance = parseFloat(decryptedBalanceStr || '0');

      if (ledger.type === 'REVENUE') {
        totalRevenue += balance;
      } else if (ledger.type === 'EXPENSE') {
        totalExpense += balance;
      }
    }

    const netProfit = totalRevenue - totalExpense;

    res.json({
      revenue: totalRevenue,
      expense: totalExpense,
      netProfit,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error calculating PnL' });
  }
};

export const getOwnerDashboard = async (req: Request, res: Response) => {
  try {
    // Fetch aggregated KPIs for the top-level owner dashboard
    // Note: In a production app with large datasets, these would be cached.
    const activeLots = await prisma.processingLot.count({ where: { status: 'IN_PROGRESS' } });
    
    // Decrypt today's sales total
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todaySales = await prisma.salesOrder.findMany({
      where: { orderDate: { gte: today } }
    });

    let todaySalesTotal = 0;
    for (const sale of todaySales) {
      const decStr = await encryptService.decrypt(sale.encryptedTotal);
      todaySalesTotal += parseFloat(decStr || '0');
    }

    res.json({
      activeLots,
      todaySalesTotal,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};
