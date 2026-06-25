import { Router } from 'express';
import { createCustomer, createOrder, dispatchOrder, getOrders } from '../controllers/salesController';

const router = Router();

router.post('/customers', createCustomer);
router.post('/orders', createOrder);
router.put('/orders/:id/dispatch', dispatchOrder);
router.get('/orders', getOrders);

export default router;
