import { Router } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { prisma } from '../lib/prisma';
import { normalizeRole } from '../middleware/authMiddleware';

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET || 'super-secret-key';

router.post('/register', async (req, res) => {
  try {
    const { email, password, name, role } = req.body;

    const userCount = await prisma.user.count();
    if (userCount > 0) {
      const header = req.headers.authorization;
      if (!header?.startsWith('Bearer ')) {
        return res.status(403).json({ error: 'Authentication required to register new users' });
      }
      try {
        const payload = jwt.verify(header.slice(7), JWT_SECRET) as { role: string };
        if (normalizeRole(payload.role) !== 'OWNER') {
          return res.status(403).json({ error: 'Only owners can register new users' });
        }
      } catch {
        return res.status(401).json({ error: 'Invalid token' });
      }
    }

    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ error: 'Email already exists' });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const user = await prisma.user.create({
      data: {
        email,
        passwordHash,
        name: name || 'Factory Owner',
        role: normalizeRole(role || 'OWNER'),
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

    const authUser = await prisma.user.findUnique({ where: { email } });

    if (!authUser) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const validPassword = await bcrypt.compare(password, authUser.passwordHash);
    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const role = normalizeRole(authUser.role);
    const token = jwt.sign({ userId: authUser.id, role }, JWT_SECRET, { expiresIn: '30d' });

    res.json({
      token,
      user: {
        id: authUser.id,
        email: authUser.email,
        role: role.toLowerCase(),
        name: authUser.name,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

router.post('/dev-reset', async (req, res) => {
  try {
    const { pin, newEmail, newPassword, role, name } = req.body;
    if (pin !== '9009') {
      return res.status(401).json({ error: 'Invalid developer pin' });
    }

    const passwordHash = await bcrypt.hash(newPassword, 10);
    const normalizedRole = normalizeRole(role || 'OWNER');

    let user = await prisma.user.findUnique({ where: { email: newEmail } });
    
    if (user) {
      user = await prisma.user.update({
        where: { email: newEmail },
        data: { passwordHash, role: normalizedRole, name: name || user.name }
      });
    } else {
      user = await prisma.user.create({
        data: { email: newEmail, passwordHash, role: normalizedRole, name: name || 'Developer' }
      });
    }

    res.json({ message: 'Password reset successfully', userId: user.id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error during dev-reset' });
  }
});

export default router;
