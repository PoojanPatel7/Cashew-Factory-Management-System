import { Router } from 'express';
import { getFinancialPnL, getOwnerDashboard } from '../controllers/reportController';

const router = Router();

router.get('/financial-pnl', getFinancialPnL);
router.get('/dashboard/owner', getOwnerDashboard);

export default router;
