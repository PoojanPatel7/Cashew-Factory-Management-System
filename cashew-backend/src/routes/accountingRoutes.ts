import { Router } from 'express';
import { logTransaction, getTransactions, getAccounts } from '../controllers/accountingController';

const router = Router();

router.post('/transactions', logTransaction);
router.get('/transactions', getTransactions);
router.get('/accounts', getAccounts);

export default router;
