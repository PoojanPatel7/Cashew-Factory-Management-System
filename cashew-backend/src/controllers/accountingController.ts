import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { encryptService } from '../services/encryptService';

const prisma = new PrismaClient();

export const logTransaction = async (req: Request, res: Response) => {
  try {
    const { description, debitAccountId, creditAccountId, amount, referenceId } = req.body;

    const encryptedAmount = await encryptService.encrypt(amount.toString());

    await prisma.$transaction(async (tx) => {
      // Create double entry log
      await tx.transaction.create({
        data: {
          description,
          debitAccountId,
          creditAccountId,
          encryptedAmount,
          referenceId,
        },
      });

      // We technically need to update the LedgerAccount balances here as well.
      // But since balances are encrypted, we can't do `increment: amount` in Prisma directly.
      // 1. Fetch current debit account balance
      const debitAccount = await tx.ledgerAccount.findUnique({ where: { id: debitAccountId } });
      const creditAccount = await tx.ledgerAccount.findUnique({ where: { id: creditAccountId } });

      if (!debitAccount || !creditAccount) throw new Error('Account not found');

      const debitBalanceStr = await encryptService.decrypt(debitAccount.encryptedBalance);
      const creditBalanceStr = await encryptService.decrypt(creditAccount.encryptedBalance);

      const debitBalance = parseFloat(debitBalanceStr || '0');
      const creditBalance = parseFloat(creditBalanceStr || '0');

      // Update in memory (Simplified for Asset/Expense vs Liability/Equity/Revenue)
      const newDebitBalance = debitBalance + parseFloat(amount);
      const newCreditBalance = creditBalance - parseFloat(amount);

      const newEncryptedDebit = await encryptService.encrypt(newDebitBalance.toString());
      const newEncryptedCredit = await encryptService.encrypt(newCreditBalance.toString());

      await tx.ledgerAccount.update({
        where: { id: debitAccountId },
        data: { encryptedBalance: newEncryptedDebit },
      });

      await tx.ledgerAccount.update({
        where: { id: creditAccountId },
        data: { encryptedBalance: newEncryptedCredit },
      });
    });

    res.status(201).json({ message: 'Transaction logged securely' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const getTransactions = async (req: Request, res: Response) => {
  try {
    const transactions = await prisma.transaction.findMany({
      orderBy: { date: 'desc' },
      include: {
        debitAccount: true,
        creditAccount: true,
      }
    });

    const decrypted = await Promise.all(transactions.map(async (t) => {
      const amount = await encryptService.decrypt(t.encryptedAmount);
      return {
        ...t,
        amount: parseFloat(amount || '0'),
        encryptedAmount: undefined,
      };
    }));

    res.json(decrypted);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const getAccounts = async (req: Request, res: Response) => {
  try {
    const accounts = await prisma.ledgerAccount.findMany();
    const decrypted = await Promise.all(accounts.map(async (a) => {
      const balance = await encryptService.decrypt(a.encryptedBalance);
      return {
        ...a,
        balance: parseFloat(balance || '0'),
        encryptedBalance: undefined,
      };
    }));
    res.json(decrypted);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};
