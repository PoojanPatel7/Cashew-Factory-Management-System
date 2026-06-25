import { Router } from 'express';
import { getInventory, adjustStock } from '../controllers/inventoryController';

const router = Router();

router.get('/stock', getInventory);
router.post('/adjust', adjustStock);

export default router;
