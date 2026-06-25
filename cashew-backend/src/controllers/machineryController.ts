import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const registerMachine = async (req: Request, res: Response) => {
  try {
    const { name, modelNumber } = req.body;

    const machine = await prisma.machine.create({
      data: {
        name,
        modelNumber,
        status: 'IDLE',
      },
    });

    res.status(201).json({ message: 'Machine registered', id: machine.id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const logTelemetry = async (req: Request, res: Response) => {
  try {
    const { machineId, temperature, pressure, powerKw } = req.body;

    // Ideally, we'd emit a WebSocket event right here for live dashboard
    // global.io.emit('telemetry_update', req.body);

    await prisma.machineTelemetry.create({
      data: {
        machineId,
        temperature,
        pressure,
        powerKw,
      },
    });

    res.status(201).json({ message: 'Telemetry logged' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const logMaintenance = async (req: Request, res: Response) => {
  try {
    const { machineId, description, cost, technician } = req.body;

    await prisma.$transaction(async (tx) => {
      await tx.maintenanceLog.create({
        data: {
          machineId,
          description,
          cost,
          technician,
        },
      });

      await tx.machine.update({
        where: { id: machineId },
        data: { status: 'MAINTENANCE' },
      });
    });

    res.status(201).json({ message: 'Maintenance logged securely' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};
