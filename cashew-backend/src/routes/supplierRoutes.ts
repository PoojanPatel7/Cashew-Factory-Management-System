import { Router } from 'express';
import { createSupplier, getSuppliers } from '../controllers/supplierController';

const router = Router();

router.post('/', createSupplier);
router.get('/', getSuppliers);

export default router;
