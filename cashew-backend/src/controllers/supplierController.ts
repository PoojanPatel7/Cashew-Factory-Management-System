import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { encryptService } from '../services/encryptService';

const prisma = new PrismaClient();

export const createSupplier = async (req: Request, res: Response) => {
  try {
    const { name, phone, bankDetails, gstin } = req.body;

    const encryptedName = await encryptService.encrypt(name);
    const encryptedPhone = await encryptService.encrypt(phone);
    const encryptedBankDetails = await encryptService.encrypt(bankDetails);

    const supplier = await prisma.supplier.create({
      data: {
        encryptedName,
        encryptedPhone,
        encryptedBankDetails,
        gstin,
      },
    });

    res.status(201).json({ message: 'Supplier created', id: supplier.id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const getSuppliers = async (req: Request, res: Response) => {
  try {
    const suppliers = await prisma.supplier.findMany();
    
    const decryptedSuppliers = await Promise.all(suppliers.map(async (sup) => {
      const name = await encryptService.decrypt(sup.encryptedName);
      const phone = await encryptService.decrypt(sup.encryptedPhone);
      
      return {
        id: sup.id,
        name: name,
        phone: phone,
        bankDetails: await encryptService.decrypt(sup.encryptedBankDetails),
        gstin: sup.gstin,
        status: sup.status === 'ACTIVE' ? 'Active' : sup.status,
        // Mock fields expected by UI
        location: 'Local Region',
        rating: 4.5,
        contactPerson: name.split(' ')[0],
      };
    }));

    res.json(decryptedSuppliers);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};
