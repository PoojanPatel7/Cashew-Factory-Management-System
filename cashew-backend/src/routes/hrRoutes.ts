import { Router } from 'express';
import { createEmployee, checkIn, logPieceWork, getPayroll, getEmployees, generatePassword, deleteEmployee, updateEmployee } from '../controllers/hrController';

const router = Router();

router.post('/employees', createEmployee);
router.get('/employees', getEmployees);
router.post('/employees/:id/generate-password', generatePassword);
router.delete('/employees/:id', deleteEmployee);
router.put('/employees/:id', updateEmployee);

router.post('/attendance/check-in', checkIn);
router.post('/piece-work', logPieceWork);
router.get('/payroll', getPayroll);

export default router;
