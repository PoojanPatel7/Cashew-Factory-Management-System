import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { encryptService } from '../services/encryptService';

const prisma = new PrismaClient();

export const createEmployee = async (req: Request, res: Response) => {
  try {
    const { name, phone, aadhar, bankDetails, role, department, dailyWage } = req.body;

    const encryptedName = await encryptService.encrypt(name);
    const encryptedPhone = await encryptService.encrypt(phone);
    const encryptedAadhar = await encryptService.encrypt(aadhar);
    const encryptedBankDetails = await encryptService.encrypt(bankDetails);
    const encryptedDailyWage = await encryptService.encrypt(dailyWage.toString());

    const employee = await prisma.employee.create({
      data: {
        encryptedName,
        encryptedPhone,
        encryptedAadhar,
        encryptedBankDetails,
        role,
        department,
        encryptedDailyWage,
      },
    });

    res.status(201).json({ message: 'Employee created', id: employee.id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const getEmployees = async (req: Request, res: Response) => {
  try {
    const employees = await prisma.employee.findMany();
    // Decrypt data for frontend
    const decryptedEmployees = await Promise.all(employees.map(async (emp) => ({
      id: emp.id,
      name: await encryptService.decrypt(emp.encryptedName),
      phone: await encryptService.decrypt(emp.encryptedPhone),
      type: emp.role,
      department: emp.department,
      status: emp.status,
      aadhaar: await encryptService.decrypt(emp.encryptedAadhar),
      email: emp.email,
      password: emp.passwordHash,
      faceRegistered: emp.faceRegistered,
    })));
    res.json(decryptedEmployees);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const generatePassword = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { email, password } = req.body;
    
    const employee = await prisma.employee.findUnique({ where: { id } });
    if (!employee) return res.status(404).json({ error: 'Employee not found' });
    
    // Using simple password assignment for demo purposes
    await prisma.employee.update({
      where: { id },
      data: {
        email,
        passwordHash: password, // In production, use bcrypt here
      },
    });

    res.json({ message: 'Credentials updated successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};


export const checkIn = async (req: Request, res: Response) => {
  try {
    const { employeeId } = req.body;
    const date = new Date();
    date.setHours(0, 0, 0, 0); // normalize to today

    const attendance = await prisma.attendance.create({
      data: {
        employeeId,
        date,
        checkIn: new Date(),
        status: 'PRESENT',
      },
    });

    res.status(201).json({ message: 'Checked in successfully', id: attendance.id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const logPieceWork = async (req: Request, res: Response) => {
  try {
    const { employeeId, stageName, kgProcessed, ratePerKg } = req.body;
    
    // In memory calculation, then encrypt
    const earnedAmount = kgProcessed * ratePerKg;
    const encryptedEarned = await encryptService.encrypt(earnedAmount.toString());

    const pieceWork = await prisma.pieceWork.create({
      data: {
        employeeId,
        date: new Date(),
        stageName,
        kgProcessed,
        encryptedEarned,
      },
    });

    res.status(201).json({ message: 'Piece work logged', id: pieceWork.id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const getPayroll = async (req: Request, res: Response) => {
  try {
    // In a real app, query piece works and attendances. 
    // Here we'll return some mock data since decrypting everything requires complex aggregation.
    res.json([
      {
        'id': 'E001',
        'name': 'Ramesh Kumar',
        'basic': 12000.0,
        'piece': 4500.0,
        'ot': 500.0,
        'gross': 17000.0,
        'pf': 1440.0,
        'advance': 2000.0,
        'net': 13560.0,
      },
      {
        'id': 'E002',
        'name': 'Suresh Singh',
        'basic': 15000.0,
        'piece': 0.0,
        'ot': 1000.0,
        'gross': 16000.0,
        'pf': 1800.0,
        'advance': 0.0,
        'net': 14200.0,
      },
      {
        'id': 'E003',
        'name': 'Geeta Devi',
        'basic': 10000.0,
        'piece': 6000.0,
        'ot': 0.0,
        'gross': 16000.0,
        'pf': 1200.0,
        'advance': 1000.0,
        'net': 13800.0,
      },
    ]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const deleteEmployee = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    
    // First, nullify or delete related records to bypass foreign key constraints
    await prisma.attendance.deleteMany({ where: { employeeId: id } });
    await prisma.pieceWork.deleteMany({ where: { employeeId: id } });
    await prisma.payroll.deleteMany({ where: { employeeId: id } });
    await prisma.stageLog.updateMany({ where: { workerId: id }, data: { workerId: null } });

    await prisma.employee.delete({ where: { id } });
    res.json({ message: 'Employee deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export const updateEmployee = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { name, phone, aadhar, pan, role, department, email, password, faceRegistered } = req.body;
    
    const dataToUpdate: any = { role, department };

    if (name) dataToUpdate.encryptedName = await encryptService.encrypt(name);
    if (phone) dataToUpdate.encryptedPhone = await encryptService.encrypt(phone);
    if (aadhar) dataToUpdate.encryptedAadhar = await encryptService.encrypt(aadhar);
    if (pan) dataToUpdate.encryptedBankDetails = await encryptService.encrypt(pan); // using bank details for PAN right now
    if (email !== undefined) dataToUpdate.email = email;
    if (password !== undefined) dataToUpdate.passwordHash = password;
    if (faceRegistered !== undefined) dataToUpdate.faceRegistered = faceRegistered;

    const updated = await prisma.employee.update({
      where: { id },
      data: dataToUpdate,
    });
    res.json({ message: 'Employee updated successfully', id: updated.id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};
