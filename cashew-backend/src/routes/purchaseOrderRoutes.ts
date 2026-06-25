import { Router } from 'express';
import { createPO, receivePO, getPOs } from '../controllers/purchaseOrderController';

const router = Router();

router.get('/', getPOs);
router.post('/', createPO);
router.put('/:id/receive', receivePO);

export default router;
