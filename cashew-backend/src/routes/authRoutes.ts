import { Router } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';
import { encryptService } from '../services/encryptService';

const router = Router();
const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || 'super-secret-key';

router.post('/register', async (req, res) => {
  try {
    const { email, password, name, role } = req.body;

    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ error: 'Email already exists' });
    }

    const passwordHash = await bcrypt.hash(password, 10);
    // Use the encrypt engine to secure the user's name
    const encryptedName = await encryptService.encrypt(name);

    const user = await prisma.user.create({
      data: {
        email,
        passwordHash,
        role: role || 'WORKER',
        encryptedName,
      },
    });

    res.status(201).json({ message: 'User registered successfully', userId: user.id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    let authUser: any = await prisma.user.findUnique({ where: { email } });
    let isEmployee = false;
    let employeeData: any = null;

    if (!authUser) {
      // Fallback to Employee login
      const emp = await prisma.employee.findFirst({ where: { email } });
      if (emp) {
        isEmployee = true;
        employeeData = emp;
        authUser = {
          id: emp.id,
          email: emp.email,
          passwordHash: emp.passwordHash,
          role: emp.role, // e.g. "Worker", "Manager"
          encryptedName: emp.encryptedName,
        };
      }
    }

    if (!authUser) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Since we used raw password in HR for demo (or bcrypt if updated), handle both:
    let validPassword = false;
    if (isEmployee) {
      // We set passwordHash as raw text in setCredentials for demo purposes. Check raw first, then bcrypt if you want
      validPassword = password === authUser.passwordHash;
    } else {
      validPassword = await bcrypt.compare(password, authUser.passwordHash);
    }

    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign({ userId: authUser.id, role: authUser.role }, JWT_SECRET, { expiresIn: '1d' });
    
    // Decrypt the name for the frontend
    const decryptedName = await encryptService.decrypt(authUser.encryptedName);

    res.json({
      token,
      user: {
        id: authUser.id,
        email: authUser.email,
        role: authUser.role,
        name: decryptedName,
        isEmployee: isEmployee,
        faceRegistered: isEmployee ? employeeData.faceRegistered : true,
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

export default router;
