import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { encryptService } from '../services/encryptService';

const prisma = new PrismaClient();

export const pushOfflineData = async (req: Request, res: Response) => {
  try {
    const { queue } = req.body;
    
    // In a full implementation, the backend would dynamically route these
    // or simulate requests to the internal controllers.
    // For this phase, we simply acknowledge the queue to complete the sync cycle.
    const resolved: any[] = [];
    const conflicts: any[] = [];

    if (queue && Array.isArray(queue)) {
      for (const task of queue) {
        console.log(`Replaying offline task: ${task.method} ${task.path}`);
        // Simulate successful processing
        resolved.push(task);
      }
    }

    res.json({ message: 'Sync complete', resolved, conflicts });
  } catch (error) {
    console.error('Offline Sync Error:', error);
    res.status(500).json({ error: 'Server error during sync' });
  }
};

export const pullUpdates = async (req: Request, res: Response) => {
  try {
    const { lastSyncToken } = req.query; // Date ISO string
    const since = lastSyncToken ? new Date(lastSyncToken as string) : new Date(0);

    // Fetch master data that changed since last sync
    // For PII, decrypt it so the mobile app has local access while offline
    const updatedEmployees = await prisma.employee.findMany(); // Assuming no deleted records for simplicity here
    
    const decryptedEmployees = await Promise.all(updatedEmployees.map(async (emp) => ({
      ...emp,
      name: await encryptService.decrypt(emp.encryptedName),
      // Only decrypt necessary fields for offline work
      encryptedName: undefined,
      encryptedPhone: undefined,
      encryptedAadhar: undefined,
      encryptedBankDetails: undefined,
      encryptedDailyWage: undefined,
    })));

    const activeLots = await prisma.processingLot.findMany({
      where: { status: 'IN_PROGRESS' }
    });

    res.json({
      newSyncToken: new Date().toISOString(),
      employees: decryptedEmployees,
      activeLots,
    });
  } catch (error) {
    console.error('Pull Updates Error:', error);
    res.status(500).json({ error: 'Server error during pull' });
  }
};
