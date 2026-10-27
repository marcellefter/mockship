import { useState } from 'react';
import type { CreateInvoiceInput } from '../../../api/client';
import { Button, Modal, TextField } from '../../../shared/components';
import { currencyOptions, mockCustomers } from '../mockData';
import { SelectField } from '../SelectField';

interface NewInvoiceModalProps {
  open: boolean;
  onClose: () => void;
  onCreate: (input: CreateInvoiceInput) => void;
}

export function NewInvoiceModal({ open, onClose, onCreate }: NewInvoiceModalProps) {
  const [customerId, setCustomerId] = useState('');
  const [total, setTotal] = useState('');
  const [currency, setCurrency] = useState(currencyOptions[0]);
  const [dueDate, setDueDate] = useState('');
  const valid = customerId !== '' && Number(total) > 0 && dueDate !== '';

  const reset = () => {
    setCustomerId('');
    setTotal('');
    setCurrency(currencyOptions[0]);
    setDueDate('');
  };
  const handleClose = () => {
    reset();
    onClose();
  };
  const handleCreate = () => {
    onCreate({ customerId, total: Number(total), currency, dueDate });
    reset();
  };

  return (
    <Modal
      title="New invoice"
      open={open}
      onClose={handleClose}
      footer={
        <>
          <Button onClick={handleClose}>Cancel</Button>
          <Button variant="primary" disabled={!valid} onClick={handleCreate}>Create invoice</Button>
        </>
      }
    >
      <SelectField
        label="Customer"
        value={customerId}
        onChange={(e) => setCustomerId(e.target.value)}
        options={[{ value: '', label: 'Choose a customer' }, ...mockCustomers.filter((c) => c.status === 'active').map((c) => ({ value: c.id, label: c.name }))]}
      />
      <TextField label="Total" type="number" min="0" step="0.01" value={total} onChange={(e) => setTotal(e.target.value)} />
      <SelectField
        label="Currency"
        value={currency}
        onChange={(e) => setCurrency(e.target.value)}
        options={currencyOptions.map((c) => ({ value: c, label: c }))}
      />
      <TextField label="Due date" type="date" value={dueDate} onChange={(e) => setDueDate(e.target.value)} />
    </Modal>
  );
}
