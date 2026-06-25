import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import authRoutes from './routes/authRoutes';

import supplierRoutes from './routes/supplierRoutes';
import inventoryRoutes from './routes/inventoryRoutes';
import purchaseOrderRoutes from './routes/purchaseOrderRoutes';
import processingRoutes from './routes/processingRoutes';
import qualityRoutes from './routes/qualityRoutes';
import hrRoutes from './routes/hrRoutes';
import accountingRoutes from './routes/accountingRoutes';
import salesRoutes from './routes/salesRoutes';
import machineryRoutes from './routes/machineryRoutes';
import reportRoutes from './routes/reportRoutes';
import syncRoutes from './routes/syncRoutes';

import { rateLimit } from 'express-rate-limit';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 4000;

app.use(cors());
app.use(helmet());
app.use(express.json());

// Prevent brute-force attacks on login
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 login requests per `window`
  message: 'Too many requests from this IP, please try again later.',
});

app.use('/api/auth', authLimiter, authRoutes);
app.use('/api/suppliers', supplierRoutes);
app.use('/api/inventory', inventoryRoutes);
app.use('/api/procurement/pos', purchaseOrderRoutes);
app.use('/api/processing', processingRoutes);
app.use('/api/quality', qualityRoutes);
app.use('/api/hr', hrRoutes);
app.use('/api/accounting', accountingRoutes);
app.use('/api/sales', salesRoutes);
app.use('/api/machinery', machineryRoutes);
app.use('/api/reports', reportRoutes);
app.use('/api/sync', syncRoutes);

app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Cashew Backend Running' });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
