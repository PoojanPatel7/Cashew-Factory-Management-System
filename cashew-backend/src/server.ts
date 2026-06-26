import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './routes/authRoutes';
import stockRoutes from './routes/stockRoutes';
import factoryRoutes from './routes/factoryRoutes';
import { authMiddleware } from './middleware/authMiddleware';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 4000;

app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', message: 'CashewPro Stock Tracker Running' });
});

// Auth (login/register)
app.use('/api/auth', authRoutes);

// Protected stock routes
app.use('/api', authMiddleware);
app.use('/api/factories', factoryRoutes);
app.use('/api/stock', stockRoutes);

app.listen(PORT, () => {
  console.log(`🥜 CashewPro Stock Tracker running on http://localhost:${PORT}`);
});
