import { Router } from 'express';
import { getFactories, createFactory, updateFactory, getFactory, deleteFactory, resetAllData } from '../controllers/factoryController';
import { requireRole } from '../middleware/authMiddleware';

const router = Router();

router.get('/', getFactories);
router.post('/', requireRole(['OWNER']), createFactory);
router.get('/:id', getFactory);
router.put('/:id', requireRole(['OWNER']), updateFactory);
router.delete('/reset-all-data/now', requireRole(['OWNER']), resetAllData);
router.delete('/:id', requireRole(['OWNER']), deleteFactory);

export default router;
