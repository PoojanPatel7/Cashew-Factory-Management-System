import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';

export const getFactories = async (req: Request, res: Response) => {
  try {
    const factories = await prisma.factory.findMany();
    res.json(factories);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
};

export const createFactory = async (req: Request, res: Response) => {
  try {
    const { name, weighAtEveryStage } = req.body;
    const factory = await prisma.factory.create({
      data: {
        name,
        weighAtEveryStage: weighAtEveryStage ?? true,
      },
    });
    res.status(201).json(factory);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
};

export const updateFactory = async (req: Request, res: Response) => {
  try {
    const id = req.params.id as string;
    const { name, weighAtEveryStage } = req.body;
    const factory = await prisma.factory.update({
      where: { id },
      data: { name, weighAtEveryStage },
    });
    res.json(factory);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
};

export const getFactory = async (req: Request, res: Response) => {
  const factory = await prisma.factory.findUnique({ where: { id: req.params.id as string } });
  if (!factory) return res.status(404).json({ error: 'Factory not found' });
  res.json(factory);
};

export const deleteFactory = async (req: Request, res: Response) => {
  try {
    await prisma.factory.delete({ where: { id: req.params.id as string } });
    res.json({ message: 'Factory deleted' });
  } catch (e) {
    res.status(400).json({ error: 'Cannot delete factory with existing data' });
  }
};

export const resetAllData = async (req: Request, res: Response) => {
  try {
    await prisma.$transaction([
      prisma.user.updateMany({ data: { factoryId: null } }),
      prisma.activityLog.deleteMany(),
      prisma.dispatch.deleteMany(),
      prisma.finishedStock.deleteMany(),
      prisma.processingStep.deleteMany(),
      prisma.lot.deleteMany(),
      prisma.sortingRawStock.deleteMany(),
      prisma.sorting.deleteMany(),
      prisma.rawStock.deleteMany(),
      prisma.factory.deleteMany()
    ]);
    res.json({ message: 'All business data deleted successfully, user data preserved.' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to reset data' });
  }
};
