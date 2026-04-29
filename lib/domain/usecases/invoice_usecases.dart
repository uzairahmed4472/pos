import '../entities/invoice.dart';
import '../entities/sale.dart';
import '../repositories/invoice_repository.dart';

class GetInvoicesUseCase {
  final InvoiceRepository _repository;

  GetInvoicesUseCase(this._repository);

  Future<List<Invoice>> call() async {
    return await _repository.getInvoices();
  }
}

class GetInvoiceByIdUseCase {
  final InvoiceRepository _repository;

  GetInvoiceByIdUseCase(this._repository);

  Future<Invoice?> call(String id) async {
    return await _repository.getInvoiceById(id);
  }
}

class CreateInvoiceUseCase {
  final InvoiceRepository _repository;

  CreateInvoiceUseCase(this._repository);

  Future<Invoice> call(Invoice invoice) async {
    return await _repository.createInvoice(invoice);
  }
}

class CreateInvoiceFromSaleUseCase {
  final InvoiceRepository _repository;

  CreateInvoiceFromSaleUseCase(this._repository);

  Future<Invoice> call(Sale sale) async {
    final invoiceNumber = await _repository.generateInvoiceNumber();
    final invoice = Invoice.fromSale(sale, invoiceNumber);
    return await _repository.createInvoice(invoice);
  }
}

class UpdateInvoiceUseCase {
  final InvoiceRepository _repository;

  UpdateInvoiceUseCase(this._repository);

  Future<Invoice> call(Invoice invoice) async {
    return await _repository.updateInvoice(invoice);
  }
}

class DeleteInvoiceUseCase {
  final InvoiceRepository _repository;

  DeleteInvoiceUseCase(this._repository);

  Future<void> call(String id) async {
    return await _repository.deleteInvoice(id);
  }
}

class GetInvoicesByDateRangeUseCase {
  final InvoiceRepository _repository;

  GetInvoicesByDateRangeUseCase(this._repository);

  Future<List<Invoice>> call(DateTime startDate, DateTime endDate) async {
    return await _repository.getInvoicesByDateRange(startDate, endDate);
  }
}

class GetInvoicesByCustomerUseCase {
  final InvoiceRepository _repository;

  GetInvoicesByCustomerUseCase(this._repository);

  Future<List<Invoice>> call(String customerId) async {
    return await _repository.getInvoicesByCustomer(customerId);
  }
}

class GetInvoicesBySellerUseCase {
  final InvoiceRepository _repository;

  GetInvoicesBySellerUseCase(this._repository);

  Future<List<Invoice>> call(String sellerId) async {
    return await _repository.getInvoicesBySeller(sellerId);
  }
}

class GenerateInvoiceNumberUseCase {
  final InvoiceRepository _repository;

  GenerateInvoiceNumberUseCase(this._repository);

  Future<String> call() async {
    return await _repository.generateInvoiceNumber();
  }
}
