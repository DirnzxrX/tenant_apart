import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// -----------------------------------------------------------------------------
// DTO & DATA MODELS
// -----------------------------------------------------------------------------

class AuthUser {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? phone;
  final String tenantCompany;
  final List<String> units;

  AuthUser({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.phone,
    required this.tenantCompany,
    required this.units,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      tenantCompany: json['tenant_company'] ?? '',
      units: _parseUnits(json['units']),
    );
  }

  static List<String> _parseUnits(dynamic rawUnits) {
    if (rawUnits is List) {
      return rawUnits.map((item) {
        if (item is Map<String, dynamic>) {
          final name = item['name']?.toString().trim();
          final code = item['code']?.toString().trim();
          if (name != null && name.isNotEmpty && code != null && code.isNotEmpty) {
            return '$name ($code)';
          }
          if (name != null && name.isNotEmpty) return name;
          if (code != null && code.isNotEmpty) return code;
          return item['id']?.toString() ?? '';
        }
        return item?.toString() ?? '';
      }).where((value) => value.isNotEmpty).toList();
    }

    if (rawUnits is String && rawUnits.trim().isNotEmpty) {
      return [rawUnits.trim()];
    }

    return const [];
  }
}

class AuthResponse {
  final String token;
  final String tokenType;
  final String expiresAt;
  final AuthUser user;

  AuthResponse({
    required this.token,
    required this.tokenType,
    required this.expiresAt,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      tokenType: json['token_type'] ?? '',
      expiresAt: json['expires_at'] ?? '',
      user: AuthUser.fromJson(json['user'] ?? {}),
    );
  }
}

class UserPreference {
  final String language;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool announcementEnabled;
  final bool serviceRequestEnabled;
  final bool billingEnabled;
  final bool permitEnabled;
  final bool documentEnabled;
  final bool loadingDeliveryEnabled;

  UserPreference({
    required this.language,
    required this.pushNotificationsEnabled,
    required this.emailNotificationsEnabled,
    required this.announcementEnabled,
    required this.serviceRequestEnabled,
    required this.billingEnabled,
    required this.permitEnabled,
    required this.documentEnabled,
    required this.loadingDeliveryEnabled,
  });

  factory UserPreference.fromJson(Map<String, dynamic> json) {
    return UserPreference(
      language: json['language'] ?? 'en',
      pushNotificationsEnabled: json['push_notifications_enabled'] ?? false,
      emailNotificationsEnabled: json['email_notifications_enabled'] ?? false,
      announcementEnabled: json['announcement_enabled'] ?? false,
      serviceRequestEnabled: json['service_request_enabled'] ?? false,
      billingEnabled: json['billing_enabled'] ?? false,
      permitEnabled: json['permit_enabled'] ?? false,
      documentEnabled: json['document_enabled'] ?? false,
      loadingDeliveryEnabled: json['loading_delivery_enabled'] ?? false,
    );
  }
}

class Announcement {
  final String id;
  final String category;
  final String title;
  final String content;
  final String publishedAt;

  Announcement({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
    required this.publishedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      publishedAt: json['published_at'] ?? '',
    );
  }
}

class DocumentItem {
  final String id;
  final String title;
  final String? description;
  final String mimeType;
  final int size;
  final String publishedAt;

  DocumentItem({
    required this.id,
    required this.title,
    this.description,
    required this.mimeType,
    required this.size,
    required this.publishedAt,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      mimeType: json['mime_type'] ?? '',
      size: json['size'] ?? 0,
      publishedAt: json['published_at'] ?? '',
    );
  }
}

class InboxItem {
  final String tab; 
  final String id;
  final String title;
  final String body;
  final String sentAt;

  InboxItem({
    required this.tab,
    required this.id,
    required this.title,
    required this.body,
    required this.sentAt,
  });

  factory InboxItem.fromJson(Map<String, dynamic> json) {
    return InboxItem(
      tab: json['tab'] ?? '',
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      sentAt: json['sent_at'] ?? '',
    );
  }
}

class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? deeplinkType;
  final String? deeplinkPayload;
  final bool isRead;
  final String sentAt;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.deeplinkType,
    this.deeplinkPayload,
    required this.isRead,
    required this.sentAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      deeplinkType: json['deeplink_type'],
      deeplinkPayload: json['deeplink_payload'],
      isRead: json['is_read'] ?? false,
      sentAt: json['sent_at'] ?? '',
    );
  }
}

class InvoiceItemResource {
  final String description;
  final int quantity;
  final int unitAmount;
  final String unitAmountFormatted;
  final int totalAmount;
  final String totalAmountFormatted;

  InvoiceItemResource({
    required this.description,
    required this.quantity,
    required this.unitAmount,
    required this.unitAmountFormatted,
    required this.totalAmount,
    required this.totalAmountFormatted,
  });

  factory InvoiceItemResource.fromJson(Map<String, dynamic> json) {
    return InvoiceItemResource(
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitAmount: json['unit_amount'] ?? 0,
      unitAmountFormatted: json['unit_amount_formatted'] ?? '',
      totalAmount: json['total_amount'] ?? 0,
      totalAmountFormatted: json['total_amount_formatted'] ?? '',
    );
  }
}

class PaymentTransaction {
  final String id;
  final String paymentMethod;
  final String status;
  final String? transactionRef;
  final int amount;
  final String amountFormatted;
  final String paidAt;

  PaymentTransaction({
    required this.id,
    required this.paymentMethod,
    required this.status,
    this.transactionRef,
    required this.amount,
    required this.amountFormatted,
    required this.paidAt,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? '',
      transactionRef: json['transaction_ref'],
      amount: json['amount'] ?? 0,
      amountFormatted: json['amount_formatted'] ?? '',
      paidAt: json['paid_at'] ?? '',
    );
  }
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final String status;
  final String issueDate;
  final String dueDate;
  final int totalAmount;
  final String totalAmountFormatted;
  final int paidAmount;
  final int outstandingAmount;
  final String outstandingAmountFormatted;
  final List<InvoiceItemResource> items;
  final List<PaymentTransaction> paymentHistory;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.status,
    required this.issueDate,
    required this.dueDate,
    required this.totalAmount,
    required this.totalAmountFormatted,
    required this.paidAmount,
    required this.outstandingAmount,
    required this.outstandingAmountFormatted,
    required this.items,
    this.paymentHistory = const [],
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    int parseAmount(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0; 
    }

    return Invoice(
      id: json['id'] ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
      status: json['status'] ?? '',
      issueDate: json['issue_date'] ?? '',
      dueDate: json['due_date'] ?? '',
      totalAmount: parseAmount(json['total_amount']),
      totalAmountFormatted: json['total_amount_formatted'] ?? '',
      paidAmount: parseAmount(json['paid_amount']),
      outstandingAmount: parseAmount(json['outstanding_amount']),
      outstandingAmountFormatted: json['outstanding_amount_formatted'] ?? '',
      items: (json['items'] as List?)?.map((e) => InvoiceItemResource.fromJson(e)).toList() ?? [],
      paymentHistory: (json['payment_history'] as List?)?.map((e) => PaymentTransaction.fromJson(e)).toList() ?? [],
    );
  }
}

class Attachment {
  final String id;
  final String originalName;
  final String mimeType;
  final int size;
  final String uploadedAt;

  Attachment({
    required this.id,
    required this.originalName,
    required this.mimeType,
    required this.size,
    required this.uploadedAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] ?? '',
      originalName: json['original_name'] ?? '',
      mimeType: json['mime_type'] ?? '',
      size: json['size'] ?? 0,
      uploadedAt: json['uploaded_at'] ?? '',
    );
  }
}

class StatusHistory {
  final String fromStatus;
  final String toStatus;
  final String note;
  final String occurredAt;

  StatusHistory({
    required this.fromStatus,
    required this.toStatus,
    required this.note,
    required this.occurredAt,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      fromStatus: json['from_status'] ?? '',
      toStatus: json['to_status'] ?? '',
      note: json['note'] ?? '',
      occurredAt: json['occurred_at'] ?? '',
    );
  }
}

class LoadingDelivery {
  final String id;
  final String requestNumber;
  final String activityType;
  final String description;
  final String scheduledAt;
  final String status;
  final String submittedAt;
  final List<Attachment> attachments;
  final List<StatusHistory> timeline;

  LoadingDelivery({
    required this.id,
    required this.requestNumber,
    required this.activityType,
    required this.description,
    required this.scheduledAt,
    required this.status,
    required this.submittedAt,
    required this.attachments,
    required this.timeline,
  });

  factory LoadingDelivery.fromJson(Map<String, dynamic> json) {
    return LoadingDelivery(
      id: json['id'] ?? '',
      requestNumber: json['request_number'] ?? '',
      activityType: json['activity_type'] ?? '',
      description: json['description'] ?? '',
      scheduledAt: json['scheduled_at'] ?? '',
      status: json['status'] ?? '',
      submittedAt: json['submitted_at'] ?? '',
      attachments: (json['attachments'] as List?)?.map((e) => Attachment.fromJson(e)).toList() ?? [],
      timeline: (json['timeline'] as List?)?.map((e) => StatusHistory.fromJson(e)).toList() ?? [],
    );
  }
}

class PermitCategory {
  final String id;
  final String name;
  final String code;
  final String description;
  final bool isActive;

  PermitCategory({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.isActive,
  });

  factory PermitCategory.fromJson(Map<String, dynamic> json) {
    return PermitCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}

class Permit {
  final String id;
  final String requestNumber;
  final String title;
  final String description;
  final String status;
  final String submittedAt;
  final PermitCategory? category;
  final List<Attachment> attachments;
  final List<StatusHistory> timeline;

  Permit({
    required this.id,
    required this.requestNumber,
    required this.title,
    required this.description,
    required this.status,
    required this.submittedAt,
    this.category,
    required this.attachments,
    required this.timeline,
  });

  factory Permit.fromJson(Map<String, dynamic> json) {
    return Permit(
      id: json['id'] ?? '',
      requestNumber: json['request_number'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      submittedAt: json['submitted_at'] ?? '',
      category: json['category'] != null ? PermitCategory.fromJson(json['category']) : null,
      attachments: (json['attachments'] as List?)?.map((e) => Attachment.fromJson(e)).toList() ?? [],
      timeline: (json['timeline'] as List?)?.map((e) => StatusHistory.fromJson(e)).toList() ?? [],
    );
  }
}

// --- NEW MODELS FOR SERVICE REQUEST ---

class ServiceRequestCategory {
  final String id;
  final String name;
  final String code;
  final String description;
  final bool isActive;

  ServiceRequestCategory({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.isActive,
  });

  factory ServiceRequestCategory.fromJson(Map<String, dynamic> json) {
    return ServiceRequestCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}

class ServiceRequestUnit {
  final String id;
  final String name;
  final String code;

  ServiceRequestUnit({
    required this.id,
    required this.name,
    required this.code,
  });

  factory ServiceRequestUnit.fromJson(Map<String, dynamic> json) {
    return ServiceRequestUnit(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class ServiceRequest {
  final String id;
  final String requestNumber;
  final String title;
  final String description;
  final String status;
  final String submittedAt;
  final ServiceRequestCategory? category;
  final ServiceRequestUnit? unit;
  final List<Attachment> attachments;
  final List<StatusHistory> timeline;

  ServiceRequest({
    required this.id,
    required this.requestNumber,
    required this.title,
    required this.description,
    required this.status,
    required this.submittedAt,
    this.category,
    this.unit,
    required this.attachments,
    this.timeline = const [],
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] ?? '',
      requestNumber: json['request_number'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      submittedAt: json['submitted_at'] ?? '',
      category: json['category'] != null ? ServiceRequestCategory.fromJson(json['category']) : null,
      unit: json['unit'] != null ? ServiceRequestUnit.fromJson(json['unit']) : null,
      attachments: (json['attachments'] as List?)?.map((e) => Attachment.fromJson(e)).toList() ?? [],
      timeline: (json['timeline'] as List?)?.map((e) => StatusHistory.fromJson(e)).toList() ?? [],
    );
  }
}


// -----------------------------------------------------------------------------
// 2. API SERVICE KESELURUHAN
// -----------------------------------------------------------------------------
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // TODO: Pastikan baseUrl ini dipindah ke .env sebelum rilis ke production
  static const String baseUrl = 'http://100.105.172.126:8000/api/v1';
  static const String demoEmail = 'tenant.demo@example.com';
  static const String demoPassword = 'password123';
  static const String _demoToken = 'demo-token';
  
  String? _cachedToken;
  String _cachedTokenType = 'Bearer';
  String? _cachedDeviceUuid;

  void setToken(String token, {String tokenType = 'Bearer'}) {
    _cachedToken = token;
    _cachedTokenType = tokenType.isNotEmpty ? tokenType : 'Bearer';
  }

  bool get _isDemoSession => _cachedToken == null || _cachedToken == _demoToken;

  AuthUser _demoProfileUser() {
    return AuthUser(
      id: 'demo-user',
      name: 'Budi Santoso',
      username: 'tenant.demo',
      email: demoEmail,
      phone: '+62 812-3456-7890',
      tenantCompany: 'PT Maju Bersama',
      units: const ['Lantai 3 - Unit 305A'],
    );
  }

  void _debug(String message) {
    if (kDebugMode) {
      debugPrint('[ApiService] $message');
    }
  }

  String _safeBody(Object? body) {
    if (body == null) return '{}';
    if (body is Map) {
      final redacted = Map<String, dynamic>.from(body.cast<String, dynamic>());
      for (final key in ['password', 'current_password', 'password_confirmation']) {
        if (redacted.containsKey(key)) {
          redacted[key] = '***';
        }
      }
      return jsonEncode(redacted);
    }
    return body.toString();
  }

  void _logRequest(String method, Uri uri, {Object? body}) {
    _debug('-> $method $uri${body == null ? '' : ' body=${_safeBody(body)}'}');
  }

  void _logResponse(String method, Uri uri, int statusCode, {Object? body}) {
    _debug('<- $method $uri [$statusCode]${body == null ? '' : ' body=${_safeBody(body)}'}');
  }

  void _logError(String method, Uri uri, Object error) {
    _debug('!! $method $uri error=$error');
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    final decoded = json.decode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{'data': decoded};
  }

  List<dynamic> _extractList(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is List) return data;
    if (data is Map && data['items'] is List) return data['items'] as List;
    return const [];
  }

  String _formatCurrency(dynamic value) {
    final amount = value is int
        ? value
        : value is String
            ? int.tryParse(value) ?? 0
            : 0;
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp $formatted';
  }

  String _shortDate(String input) {
    if (input.isEmpty) return '-';
    final parsed = DateTime.tryParse(input);
    if (parsed == null) return input;
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${parsed.day.toString().padLeft(2, '0')} ${monthNames[parsed.month - 1]} ${parsed.year}';
  }

  String _statusTone(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('done') || lower.contains('lunas') || lower.contains('approved') || lower.contains('selesai') || lower.contains('paid')) {
      return 'success';
    }
    if (lower.contains('pending') || lower.contains('menunggu') || lower.contains('due')) {
      return 'warning';
    }
    if (lower.contains('reject') || lower.contains('tolak') || lower.contains('cancel') || lower.contains('overdue')) {
      return 'danger';
    }
    return 'info';
  }

  String _normalizeInvoiceStatus(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('paid') || lower.contains('lunas') || lower.contains('settled')) {
      return 'Lunas';
    }
    if (lower.contains('overdue') || lower.contains('due') || lower.contains('pending') || lower.contains('unpaid')) {
      return 'Belum Dibayar';
    }
    return status.isEmpty ? 'Belum Dibayar' : status;
  }

  String _normalizePermitStatus(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('approve') || lower.contains('setuju') || lower.contains('accepted')) {
      return 'Disetujui';
    }
    if (lower.contains('reject') || lower.contains('tolak') || lower.contains('decline')) {
      return 'Ditolak';
    }
    if (lower.contains('wait') || lower.contains('pending') || lower.contains('menunggu')) {
      return 'Menunggu';
    }
    return status.isEmpty ? 'Menunggu' : status;
  }

  List<Map<String, String>> _demoInvoices() {
    return [
      {
        'id': 'INV/2025/05/0012',
        'desc': 'Sewa & Service Charge - Mei 2025',
        'dueDate': '31 Mei 2025',
        'amount': 'Rp 12.750.000',
        'status': 'Belum Dibayar',
        'tone': 'warning',
      },
      {
        'id': 'INV/2025/04/0011',
        'desc': 'Sewa & Service Charge - Apr 2025',
        'dueDate': '30 Apr 2025',
        'amount': 'Rp 11.810.000',
        'status': 'Belum Dibayar',
        'tone': 'warning',
      },
      {
        'id': 'INV/2025/03/0009',
        'desc': 'Sewa & Service Charge - Mar 2025',
        'dueDate': '31 Mar 2025',
        'amount': 'Rp 11.250.000',
        'status': 'Lunas',
        'tone': 'success',
      },
    ];
  }

  List<Map<String, dynamic>> _demoPermits() {
    return [
      {
        'title': 'Renovasi Toko',
        'id': '#PRM-250521-0008',
        'date': '21 Mei 2025',
        'status': 'Disetujui',
        'tone': 'success',
        'icon': Icons.approval_rounded,
      },
      {
        'title': 'Promosi & Event',
        'id': '#PRM-250519-0007',
        'date': '19 Mei 2025',
        'status': 'Menunggu',
        'tone': 'warning',
        'icon': Icons.campaign_outlined,
      },
      {
        'title': 'Instalasi Peralatan',
        'id': '#PRM-250510-0005',
        'date': '10 Mei 2025',
        'status': 'Ditolak',
        'tone': 'danger',
        'icon': Icons.precision_manufacturing_outlined,
      },
    ];
  }

  List<Map<String, dynamic>> _demoNotificationGroups() {
    return [
      {
        'dateGroup': 'Hari Ini',
        'items': [
          {
            'type': 'Pengumuman',
            'title': 'Maintenance Sistem AC Mall',
            'body': 'Pemeliharaan rutin akan dilakukan mulai pukul 00:00 WIB.',
            'time': '09:30',
            'icon': Icons.campaign_outlined,
            'tone': 'info',
            'isUnread': true,
          },
          {
            'type': 'Notifikasi',
            'title': 'Permintaan #FS-250523-0012',
            'body': 'Status permintaan Anda telah berubah menjadi diproses.',
            'time': '09:15',
            'icon': Icons.assignment_outlined,
            'tone': 'warning',
            'isUnread': true,
          },
        ],
      },
      {
        'dateGroup': 'Kemarin',
        'items': [
          {
            'type': 'Billing',
            'title': 'Invoice INV/2025/05/0012',
            'body': 'Invoice Mei 2025 sudah tersedia.',
            'time': '17:30',
            'icon': Icons.receipt_long_outlined,
            'tone': 'danger',
            'isUnread': false,
          },
        ],
      },
    ];
  }

  Map<String, String> _invoiceToView(Invoice invoice) {
    final dueDate = invoice.dueDate.isNotEmpty ? _shortDate(invoice.dueDate) : '-';
    return {
      'id': invoice.invoiceNumber.isNotEmpty ? invoice.invoiceNumber : invoice.id,
      'desc': invoice.items.isNotEmpty
          ? invoice.items.first.description
          : 'Tagihan ${invoice.invoiceNumber.isNotEmpty ? invoice.invoiceNumber : invoice.id}',
      'dueDate': dueDate,
      'amount': invoice.totalAmountFormatted.isNotEmpty
          ? invoice.totalAmountFormatted
          : _formatCurrency(invoice.totalAmount),
      'status': _normalizeInvoiceStatus(invoice.status),
      'tone': _statusTone(invoice.status),
    };
  }

  Map<String, dynamic> _permitToView(Permit permit) {
    return {
      'id': permit.requestNumber.isNotEmpty ? permit.requestNumber : permit.id,
      'title': permit.title,
      'date': _shortDate(permit.submittedAt),
      'status': _normalizePermitStatus(permit.status),
      'tone': _statusTone(permit.status),
      'icon': Icons.approval_rounded,
    };
  }

  Map<String, dynamic> _notificationToView(NotificationItem item) {
    final type = item.type.isNotEmpty ? item.type : 'Notifikasi';
    return {
      'title': item.title,
      'body': item.body,
      'type': type,
      'time': _shortDate(item.sentAt),
      'icon': type.toLowerCase().contains('pengumuman')
          ? Icons.campaign_outlined
          : Icons.notifications_active_outlined,
      'tone': item.isRead ? 'neutral' : 'info',
      'isUnread': !item.isRead,
    };
  }

  Map<String, String> get _headers {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (_cachedToken != null) {
      headers['Authorization'] = '$_cachedTokenType $_cachedToken';
    }
    headers['X-Device-Name'] = _getDeviceName();
    headers['X-Device-Uuid'] = _getDeviceUuid();
    return headers;
  }

  // -----------------------------------------------------------------------------
  // REAL API CALLS: PROFILE & PREFERENCES
  // -----------------------------------------------------------------------------

  Future<bool> login(String identifier, String password) async {
    final uri = Uri.parse('$baseUrl/auth/login');
    final payload = {
      'login': identifier,
      'password': password,
      'device_name': _getDeviceName(),
      'device_uuid': _getDeviceUuid(),
    };

    _logRequest('POST', uri, body: payload);

    try {
      final response = await http.post(
        uri,
        headers: const {
          'Accept': 'application/json',
        },
        body: payload,
      );
      final body = _decodeBody(response);
      _logResponse('POST', uri, response.statusCode, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (body['success'] == true) {
          final auth = AuthResponse.fromJson(body['data'] ?? body);
          if (auth.token.isNotEmpty) {
            setToken(auth.token, tokenType: auth.tokenType);
          }
          return true;
      }
        throw Exception(body['message'] ?? 'Login gagal');
      }

      if ((identifier == demoEmail || identifier == 'demo') && password == demoPassword) {
        _debug('Using demo login fallback.');
        setToken(_demoToken);
        return true;
      }

      throw Exception(body['message'] ?? 'Login gagal (Kode: ${response.statusCode})');
    } catch (e) {
      _logError('POST', uri, e);
      if ((identifier == demoEmail || identifier == 'demo') && password == demoPassword) {
        _debug('Using demo login fallback after error.');
        setToken(_demoToken);
        return true;
      }
      rethrow;
    }
  }

  String _getDeviceName() {
    if (kIsWeb) return 'Web';

    final platformName = defaultTargetPlatform.name;
    final operatingSystem = Platform.operatingSystem;

    if (platformName.isEmpty) return operatingSystem;
    if (platformName.toLowerCase() == operatingSystem.toLowerCase()) {
      return platformName;
    }

    return '$platformName ($operatingSystem)';
  }

  String _getDeviceUuid() {
    if (_cachedDeviceUuid != null && _cachedDeviceUuid!.isNotEmpty) {
      return _cachedDeviceUuid!;
    }

    if (kIsWeb) {
      final webUuid = 'web-${Uri.base.host.isNotEmpty ? Uri.base.host : 'tenant'}';
      _cachedDeviceUuid = webUuid;
      return webUuid;
    }

    final seed = [
      Platform.operatingSystem,
      Platform.localHostname,
      Platform.version,
      Platform.numberOfProcessors.toString(),
    ].join('|');

    final bytes = utf8.encode(seed);
    final uuid = base64Url.encode(bytes).replaceAll('=', '');
    _cachedDeviceUuid = uuid;
    return uuid;
  }

  Future<AuthUser> getProfileDetail() async {
    final uri = Uri.parse('$baseUrl/profile');
    _logRequest('GET', uri);
    if (_isDemoSession) {
      _debug('Using local profile fallback because session token is not available yet.');
      return _demoProfileUser();
    }
    try {
      final response = await http.get(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('GET', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          return AuthUser.fromJson(body['data'] ?? const {});
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil profil');
        }
      } else if (response.statusCode == 401) {
        _debug('Profile endpoint returned 401, using local fallback profile.');
        return _demoProfileUser();
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('GET', uri, e);
      if (_isDemoSession) {
        return _demoProfileUser();
      }
      rethrow;
    }
  }

  Future<Map<String, String>> getProfile() async {
    final profile = await getProfileDetail();
    return {
      'name': profile.name,
      'email': profile.email,
      'phone': profile.phone ?? '-',
      'company': profile.tenantCompany,
      'unit': profile.units.isEmpty ? '-' : profile.units.join(', '),
      'username': profile.username,
    };
  }

  Future<AuthUser> updateProfile({required String name, String? phone}) async {
    final uri = Uri.parse('$baseUrl/profile');
    final payload = {
      'name': name,
      if (phone != null) 'phone': phone,
    };
    _logRequest('PATCH', uri, body: payload);
    try {
      final response = await http.patch(
        uri, 
        headers: _headers,
        body: jsonEncode(payload),
      );
      final body = _decodeBody(response);
      _logResponse('PATCH', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          return AuthUser.fromJson(body['data'] ?? const {});
        } else {
          throw Exception(body['message'] ?? 'Gagal memperbarui profil');
        }
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('PATCH', uri, e);
      rethrow;
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final uri = Uri.parse('$baseUrl/profile/password');
    final payload = {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': confirmPassword,
    };
    _logRequest('PATCH', uri, body: payload);
    try {
      final response = await http.patch(
        uri, 
        headers: _headers,
        body: jsonEncode(payload),
      );
      final body = _decodeBody(response);
      _logResponse('PATCH', uri, response.statusCode, body: body);

      if (response.statusCode != 200) {
        throw Exception(body['message'] ?? 'Gagal memperbarui password');
      }
    } catch (e) {
      _logError('PATCH', uri, e);
      rethrow;
    }
  }

  Future<UserPreference> getUserPreferences() async {
    final uri = Uri.parse('$baseUrl/profile/preferences');
    _logRequest('GET', uri);
    if (_isDemoSession) {
      _debug('Using demo preferences fallback.');
      return UserPreference(
        language: 'id',
        pushNotificationsEnabled: true,
        emailNotificationsEnabled: true,
        announcementEnabled: true,
        serviceRequestEnabled: true,
        billingEnabled: true,
        permitEnabled: true,
        documentEnabled: true,
        loadingDeliveryEnabled: true,
      );
    }
    try {
      final response = await http.get(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('GET', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          return UserPreference.fromJson(body['data'] ?? const {});
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil preferensi pengguna');
        }
      } else if (response.statusCode == 401 && _isDemoSession) {
        _debug('Preferences endpoint returned 401 in demo session, using demo preferences.');
        return UserPreference(
          language: 'id',
          pushNotificationsEnabled: true,
          emailNotificationsEnabled: true,
          announcementEnabled: true,
          serviceRequestEnabled: true,
          billingEnabled: true,
          permitEnabled: true,
          documentEnabled: true,
          loadingDeliveryEnabled: true,
        );
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('GET', uri, e);
      if (_isDemoSession) {
        return UserPreference(
          language: 'id',
          pushNotificationsEnabled: true,
          emailNotificationsEnabled: true,
          announcementEnabled: true,
          serviceRequestEnabled: true,
          billingEnabled: true,
          permitEnabled: true,
          documentEnabled: true,
          loadingDeliveryEnabled: true,
        );
      }
      rethrow;
    }
  }


  // -----------------------------------------------------------------------------
  // REAL API CALLS: DOCUMENTS
  // -----------------------------------------------------------------------------

  Future<List<DocumentItem>> getDocuments({String? categoryId, int? perPage, String? search}) async {
    final uri = Uri.parse('$baseUrl/documents').replace(queryParameters: {
      if (categoryId != null) 'category_id': categoryId,
      if (perPage != null) 'per_page': perPage.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
    });
    _logRequest('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('GET', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          final List<dynamic> data = _extractList(body);
          return data.map((json) => DocumentItem.fromJson(json)).toList();
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil dokumen');
        }
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('GET', uri, e);
      rethrow;
    }
  }

  Future<DocumentItem> getDocumentDetail(String id) async {
    final uri = Uri.parse('$baseUrl/documents/$id');
    _logRequest('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('GET', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          return DocumentItem.fromJson(body['data'] ?? const {});
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil detail dokumen');
        }
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('GET', uri, e);
      rethrow;
    }
  }

  Future<String> downloadDocument(String id) async {
    final uri = Uri.parse('$baseUrl/documents/$id/download');
    _logRequest('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers);
      _logResponse('GET', uri, response.statusCode, body: response.body);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Gagal mengunduh dokumen (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('GET', uri, e);
      rethrow;
    }
  }

  // -----------------------------------------------------------------------------
  // REAL API CALLS: INBOX
  // -----------------------------------------------------------------------------

  Future<List<InboxItem>> getInbox({int? perPage, String? tab}) async {
    final uri = Uri.parse('$baseUrl/inbox').replace(queryParameters: {
      if (perPage != null) 'per_page': perPage.toString(),
      if (tab != null) 'tab': tab,
    });
    _logRequest('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('GET', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          final List<dynamic> data = _extractList(body);
          return data.map((json) => InboxItem.fromJson(json)).toList();
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil data inbox');
        }
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('GET', uri, e);
      rethrow;
    }
  }

  // -----------------------------------------------------------------------------
  // REAL API CALLS: INVOICE
  // -----------------------------------------------------------------------------

  Future<List<Map<String, String>>> getInvoices({
    int? perPage,
    String? search,
    String? sort,
    String? status,
  }) async {
    final uri = Uri.parse('$baseUrl/invoices').replace(queryParameters: {
      if (perPage != null) 'per_page': perPage.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (sort != null) 'sort': sort,
      if (status != null) 'status': status,
    });
    _logRequest('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('GET', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          final List<dynamic> data = _extractList(body);
          return data
              .whereType<Map>()
              .map((json) => Invoice.fromJson(json.cast<String, dynamic>()))
              .map(_invoiceToView)
              .toList();
        } else if (_isDemoSession) {
          _debug('Invoice endpoint returned non-success in demo session, using fallback invoices.');
          return _demoInvoices();
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil data invoice');
        }
      } else if (response.statusCode == 401 && _isDemoSession) {
        _debug('Invoice endpoint returned 401 in demo session, using fallback invoices.');
        return _demoInvoices();
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('GET', uri, e);
      if (_isDemoSession) {
        return _demoInvoices();
      }
      rethrow;
    }
  }

  Future<Map<String, String>> getBillingSummary() async {
    try {
      final invoices = await getInvoices();
      final totalOutstanding = invoices.fold<int>(0, (sum, item) {
        final amountText = item['amount'] ?? '0';
        final digitsOnly = amountText.replaceAll(RegExp(r'[^0-9]'), '');
        return sum + (int.tryParse(digitsOnly) ?? 0);
      });

      final overdueCount = invoices.where((item) {
        final status = (item['status'] ?? '').toLowerCase();
        return status.contains('due') || status.contains('overdue') || status.contains('pending');
      }).length;

      return {
        'totalOutstanding': _formatCurrency(totalOutstanding),
        'subtitle': '$overdueCount tagihan menunggu pembayaran',
      };
    } catch (e) {
      _debug('Billing summary fallback: $e');
      return {
        'totalOutstanding': 'Rp 0',
        'subtitle': 'Belum ada data billing tersedia',
      };
    }
  }

  Future<Invoice> getInvoiceDetail(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/invoices/$id');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['success'] == true) {
          return Invoice.fromJson(body['data']);
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil detail invoice');
        }
      } else {
        throw Exception('Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PaymentTransaction>> getInvoicePaymentHistory(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/invoices/$id/payment-history');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'] ?? [];
          return data.map((json) => PaymentTransaction.fromJson(json)).toList();
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil riwayat pembayaran');
        }
      } else {
        throw Exception('Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  // -----------------------------------------------------------------------------
  // REAL API CALLS: LOADING & DELIVERY
  // -----------------------------------------------------------------------------

  Future<List<LoadingDelivery>> getLoadingDeliveries({
    int? perPage,
    String? search,
    String? status,
  }) async {
    final uri = Uri.parse('$baseUrl/loading-deliveries').replace(queryParameters: {
      if (perPage != null) 'per_page': perPage.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null) 'status': status,
    });
    _logRequest('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('GET', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          final List<dynamic> data = _extractList(body);
          return data.map((json) => LoadingDelivery.fromJson(json)).toList();
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil data loading & delivery');
        }
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('GET', uri, e);
      rethrow;
    }
  }

  Future<void> createLoadingDelivery({
    required String unitId,
    required String activityType,
    String? description,
    required String scheduledAt,
    List<String> attachmentFilePaths = const [], 
  }) async {
    final uri = Uri.parse('$baseUrl/loading-deliveries');
    _logRequest('POST', uri, body: {
      'unit_id': unitId,
      'activity_type': activityType,
      'description': description,
      'scheduled_at': scheduledAt,
      'attachments': attachmentFilePaths.length,
    });
    try {
      var request = http.MultipartRequest('POST', uri);
      
      if (_cachedToken != null) {
        request.headers['Authorization'] = '$_cachedTokenType $_cachedToken';
      }
      request.headers['Accept'] = 'application/json';
      request.headers['X-Device-Name'] = _getDeviceName();
      request.headers['X-Device-Uuid'] = _getDeviceUuid();

      request.fields['unit_id'] = unitId;
      request.fields['activity_type'] = activityType;
      request.fields['scheduled_at'] = scheduledAt;
      if (description != null) request.fields['description'] = description;

      for (var path in attachmentFilePaths) {
        request.files.add(await http.MultipartFile.fromPath('attachments[]', path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      _logResponse('POST', uri, response.statusCode, body: response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> body = _decodeBody(response);
        if (body['success'] != true) {
           throw Exception(body['message'] ?? 'Gagal membuat permohonan');
        }
      } else {
        throw Exception('Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('POST', uri, e);
      rethrow;
    }
  }

  Future<LoadingDelivery> getLoadingDeliveryDetail(String id) async {
    final uri = Uri.parse('$baseUrl/loading-deliveries/$id');
    _logRequest('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('GET', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          return LoadingDelivery.fromJson(body['data'] ?? const {});
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil detail');
        }
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('GET', uri, e);
      rethrow;
    }
  }

  Future<List<StatusHistory>> getLoadingDeliveryTimeline(String id) async {
    final uri = Uri.parse('$baseUrl/loading-deliveries/$id/timeline');
    _logRequest('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('GET', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          final List<dynamic> data = _extractList(body);
          return data.map((json) => StatusHistory.fromJson(json)).toList();
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil timeline');
        }
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('GET', uri, e);
      rethrow;
    }
  }

  Future<void> uploadLoadingDeliveryAttachment(String id, String filePath) async {
    final uri = Uri.parse('$baseUrl/loading-deliveries/$id/attachments');
    _logRequest('POST', uri, body: {'file': filePath});
    try {
      var request = http.MultipartRequest('POST', uri);
      
      if (_cachedToken != null) {
        request.headers['Authorization'] = '$_cachedTokenType $_cachedToken';
      }
      request.headers['Accept'] = 'application/json';
      request.headers['X-Device-Name'] = _getDeviceName();
      request.headers['X-Device-Uuid'] = _getDeviceUuid();

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      _logResponse('POST', uri, response.statusCode, body: response.body);

      if (response.statusCode != 201 && response.statusCode != 200) {
        final Map<String, dynamic> body = _decodeBody(response);
        throw Exception(body['message'] ?? 'Gagal mengunggah lampiran');
      }
    } catch (e) {
      _logError('POST', uri, e);
      rethrow;
    }
  }

  // -----------------------------------------------------------------------------
  // REAL API CALLS: PERMIT & PERMIT CATEGORIES
  // -----------------------------------------------------------------------------

  Future<List<PermitCategory>> getPermitCategories() async {
    final uri = Uri.parse('$baseUrl/permit-categories');
    _logRequest('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('GET', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          final List<dynamic> data = _extractList(body);
          return data.map((json) => PermitCategory.fromJson(json)).toList();
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil kategori perizinan');
        }
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('GET', uri, e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPermits({
    int? perPage,
    String? search,
    String? status,
  }) async {
    final uri = Uri.parse('$baseUrl/permits').replace(queryParameters: {
      if (perPage != null) 'per_page': perPage.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null) 'status': status,
    });
    _logRequest('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('GET', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          final List<dynamic> data = _extractList(body);
          return data
              .whereType<Map>()
              .map((json) => Permit.fromJson(json.cast<String, dynamic>()))
              .map(_permitToView)
              .toList();
        } else if (_isDemoSession) {
          _debug('Permit endpoint returned non-success in demo session, using fallback permits.');
          final source = _demoPermits();
          if (status == null) return source;
          final filter = status.toLowerCase();
          return source.where((item) {
            final itemStatus = (item['status'] ?? '').toString().toLowerCase();
            return itemStatus.contains(filter) || filter == 'pending';
          }).toList();
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil data permit');
        }
      } else if (response.statusCode == 401 && _isDemoSession) {
        _debug('Permit endpoint returned 401 in demo session, using fallback permits.');
        final source = _demoPermits();
        if (status == null) return source;
        final filter = status.toLowerCase();
        return source.where((item) {
          final itemStatus = (item['status'] ?? '').toString().toLowerCase();
          return itemStatus.contains(filter) || filter == 'pending';
        }).toList();
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('GET', uri, e);
      if (_isDemoSession) {
        final source = _demoPermits();
        if (status == null) return source;
        final filter = status.toLowerCase();
        return source.where((item) {
          final itemStatus = (item['status'] ?? '').toString().toLowerCase();
          return itemStatus.contains(filter) || filter == 'pending';
        }).toList();
      }
      rethrow;
    }
  }

  Future<List<Map<String, String>>> getPermitMetrics() async {
    try {
      final permits = await getPermits();
      final waiting = permits.where((item) => (item['status'] ?? '').toLowerCase().contains('menunggu')).length;
      final approved = permits.where((item) => (item['status'] ?? '').toLowerCase().contains('setuju') || (item['status'] ?? '').toLowerCase().contains('approve')).length;
      final rejected = permits.where((item) => (item['status'] ?? '').toLowerCase().contains('tolak') || (item['status'] ?? '').toLowerCase().contains('reject')).length;

      return [
        {'count': permits.length.toString(), 'label': 'Total', 'tone': 'info'},
        {'count': waiting.toString(), 'label': 'Menunggu', 'tone': 'warning'},
        {'count': approved.toString(), 'label': 'Disetujui', 'tone': 'success'},
        {'count': rejected.toString(), 'label': 'Ditolak', 'tone': 'danger'},
      ];
    } catch (e) {
      _debug('Permit metrics fallback: $e');
      return [
        {'count': '0', 'label': 'Total', 'tone': 'info'},
        {'count': '0', 'label': 'Menunggu', 'tone': 'warning'},
        {'count': '0', 'label': 'Disetujui', 'tone': 'success'},
        {'count': '0', 'label': 'Ditolak', 'tone': 'danger'},
      ];
    }
  }

  Future<List<Map<String, dynamic>>> getHomeSummary() async {
    try {
      final results = await Future.wait([
        getUnreadNotificationCount(),
        getInvoices(status: 'pending'),
        getPermits(status: 'pending'),
      ]);

      final unreadNotifications = results[0] as int;
      final invoices = results[1] as List<Map<String, String>>;
      final pendingPermits = results[2] as List<Map<String, dynamic>>;

      return [
        {
          'count': unreadNotifications.toString(),
          'label': 'Notifikasi Baru',
          'tone': 'info',
          'icon': Icons.notifications_active_outlined,
        },
        {
          'count': invoices.length.toString(),
          'label': 'Tagihan Pending',
          'tone': 'warning',
          'icon': Icons.receipt_long_outlined,
        },
        {
          'count': pendingPermits.length.toString(),
          'label': 'Permit Pending',
          'tone': 'success',
          'icon': Icons.approval_rounded,
        },
      ];
    } catch (e) {
      _debug('Home summary fallback: $e');
      return [
        {
          'count': '0',
          'label': 'Notifikasi Baru',
          'tone': 'info',
          'icon': Icons.notifications_active_outlined,
        },
        {
          'count': '0',
          'label': 'Tagihan Pending',
          'tone': 'warning',
          'icon': Icons.receipt_long_outlined,
        },
        {
          'count': '0',
          'label': 'Permit Pending',
          'tone': 'success',
          'icon': Icons.approval_rounded,
        },
      ];
    }
  }

  Future<List<Map<String, dynamic>>> getQuickMenus() async {
    try {
      final prefs = await getUserPreferences();
      return [
        {
          'title': 'Service Request',
          'icon': Icons.support_agent_rounded,
          'enabled': prefs.serviceRequestEnabled,
        },
        {
          'title': 'Billing',
          'icon': Icons.receipt_long_rounded,
          'enabled': prefs.billingEnabled,
        },
        {
          'title': 'Permit & Approval',
          'icon': Icons.approval_rounded,
          'enabled': prefs.permitEnabled,
        },
        {
          'title': 'Documents',
          'icon': Icons.description_outlined,
          'enabled': prefs.documentEnabled,
        },
        {
          'title': 'Loading Delivery',
          'icon': Icons.local_shipping_outlined,
          'enabled': prefs.loadingDeliveryEnabled,
        },
        {
          'title': 'Notifications',
          'icon': Icons.notifications_outlined,
          'enabled': prefs.pushNotificationsEnabled,
        },
      ].where((item) => item['enabled'] == true).toList();
    } catch (e) {
      _debug('Quick menus fallback: $e');
      return [
        {'title': 'Service Request', 'icon': Icons.support_agent_rounded},
        {'title': 'Billing', 'icon': Icons.receipt_long_rounded},
        {'title': 'Permit & Approval', 'icon': Icons.approval_rounded},
      ];
    }
  }

  Future<List<Map<String, String>>> getAnnouncements() async {
    try {
      final groupedNotifications = await getNotifications('Pengumuman');
      final items = <Map<String, String>>[];
      for (final group in groupedNotifications) {
        final list = (group['items'] as List).cast<Map<String, dynamic>>();
        for (final item in list) {
          items.add({
            'title': item['title']?.toString() ?? '',
            'body': item['body']?.toString() ?? '',
            'date': item['time']?.toString() ?? '',
          });
        }
      }
      return items;
    } catch (e) {
      _debug('Announcements fallback: $e');
      return [
        {
          'title': 'Selamat datang di TenantHub',
          'body': 'Gunakan dashboard untuk memantau layanan dan status terbaru.',
          'date': 'Hari ini',
        },
      ];
    }
  }

  Future<List<Map<String, dynamic>>> getServiceCategories() async {
    try {
      return [
        {
          'title': 'Perbaikan Fasilitas',
          'subtitle': 'Laporkan kerusakan fasilitas dan kebutuhan perawatan.',
          'icon': Icons.build_circle_outlined,
        },
        {
          'title': 'Kebersihan',
          'subtitle': 'Ajukan permintaan terkait kebersihan area tenant.',
          'icon': Icons.cleaning_services_outlined,
        },
        {
          'title': 'IT Support',
          'subtitle': 'Bantuan jaringan, sistem, atau perangkat kerja.',
          'icon': Icons.computer_outlined,
        },
      ];
    } catch (e) {
      _debug('Service categories fallback: $e');
      return const [];
    }
  }

  Future<List<Map<String, String>>> getRequestStats() async {
    try {
      final requests = await getRecentRequests();
      final pending = requests.where((item) => (item['status'] ?? '').toLowerCase().contains('menunggu')).length;
      final inProgress = requests.where((item) => (item['status'] ?? '').toLowerCase().contains('proses')).length;
      final completed = requests.where((item) => (item['status'] ?? '').toLowerCase().contains('selesai') || (item['status'] ?? '').toLowerCase().contains('done')).length;

      return [
        {'count': requests.length.toString(), 'label': 'Total', 'tone': 'neutral'},
        {'count': pending.toString(), 'label': 'Menunggu', 'tone': 'warning'},
        {'count': inProgress.toString(), 'label': 'Diproses', 'tone': 'info'},
        {'count': completed.toString(), 'label': 'Selesai', 'tone': 'success'},
      ];
    } catch (e) {
      _debug('Request stats fallback: $e');
      return [
        {'count': '0', 'label': 'Total', 'tone': 'neutral'},
        {'count': '0', 'label': 'Menunggu', 'tone': 'warning'},
        {'count': '0', 'label': 'Diproses', 'tone': 'info'},
        {'count': '0', 'label': 'Selesai', 'tone': 'success'},
      ];
    }
  }

  Future<List<Map<String, String>>> getRecentRequests() async {
    try {
      final requests = await getPermits(perPage: 5);
      return requests
          .take(5)
          .map((item) => {
                'title': item['title']?.toString() ?? '-',
                'subtitle': item['id']?.toString() ?? '-',
                'meta': item['date']?.toString() ?? '-',
                'status': item['status']?.toString() ?? '-',
              })
          .toList();
    } catch (e) {
      _debug('Recent requests fallback: $e');
      return [
        {
          'title': 'Belum ada data',
          'subtitle': 'Periksa kembali setelah sinkronisasi selesai.',
          'meta': '-',
          'status': 'Baru',
        },
      ];
    }
  }

  Future<void> createPermit({
    required String permitCategoryId,
    required String unitId,
    required String title,
    required String description,
    List<String> attachmentFilePaths = const [], 
  }) async {
    final uri = Uri.parse('$baseUrl/permits');
    _logRequest('POST', uri, body: {
      'permit_category_id': permitCategoryId,
      'unit_id': unitId,
      'title': title,
      'description': description,
      'attachments': attachmentFilePaths.length,
    });
    try {
      var request = http.MultipartRequest('POST', uri);
      
      if (_cachedToken != null) {
        request.headers['Authorization'] = '$_cachedTokenType $_cachedToken';
      }
      request.headers['Accept'] = 'application/json';
      request.headers['X-Device-Name'] = _getDeviceName();
      request.headers['X-Device-Uuid'] = _getDeviceUuid();

      request.fields['permit_category_id'] = permitCategoryId;
      request.fields['unit_id'] = unitId;
      request.fields['title'] = title;
      request.fields['description'] = description;

      for (var path in attachmentFilePaths) {
        request.files.add(await http.MultipartFile.fromPath('attachments[]', path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      _logResponse('POST', uri, response.statusCode, body: response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> body = _decodeBody(response);
        if (body['success'] != true) {
           throw Exception(body['message'] ?? 'Gagal membuat permit');
        }
      } else {
        throw Exception('Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('POST', uri, e);
      rethrow;
    }
  }

  Future<Permit> getPermitDetail(String id) async {
    final uri = Uri.parse('$baseUrl/permits/$id');
    _logRequest('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('GET', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          return Permit.fromJson(body['data'] ?? const {});
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil detail permit');
        }
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('GET', uri, e);
      rethrow;
    }
  }

  Future<List<StatusHistory>> getPermitTimeline(String id) async {
    final uri = Uri.parse('$baseUrl/permits/$id/timeline');
    _logRequest('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('GET', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          final List<dynamic> data = _extractList(body);
          return data.map((json) => StatusHistory.fromJson(json)).toList();
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil timeline permit');
        }
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('GET', uri, e);
      rethrow;
    }
  }

  Future<void> uploadPermitAttachment(String id, String filePath) async {
    final uri = Uri.parse('$baseUrl/permits/$id/attachments');
    _logRequest('POST', uri, body: {'file': filePath});
    try {
      var request = http.MultipartRequest('POST', uri);
      
      if (_cachedToken != null) {
        request.headers['Authorization'] = '$_cachedTokenType $_cachedToken';
      }
      request.headers['Accept'] = 'application/json';
      request.headers['X-Device-Name'] = _getDeviceName();
      request.headers['X-Device-Uuid'] = _getDeviceUuid();

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      _logResponse('POST', uri, response.statusCode, body: response.body);

      if (response.statusCode != 201 && response.statusCode != 200) {
        final Map<String, dynamic> body = _decodeBody(response);
        throw Exception(body['message'] ?? 'Gagal mengunggah lampiran permit');
      }
    } catch (e) {
      _logError('POST', uri, e);
      rethrow;
    }
  }


  // -----------------------------------------------------------------------------
  // REAL API CALLS: NOTIFICATIONS
  // -----------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getNotifications([String? tab]) async {
    final uri = Uri.parse('$baseUrl/notifications').replace(queryParameters: {
      if (tab != null && tab != 'Semua') 'type': tab,
    });
    _logRequest('GET', uri);
    if (_isDemoSession) {
      _debug('Using demo notification fallback.');
      return _demoNotificationGroups();
    }
    try {
      final response = await http.get(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('GET', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          final items = _extractList(body)
              .whereType<Map>()
              .map((json) => NotificationItem.fromJson(json.cast<String, dynamic>()))
              .map(_notificationToView)
              .toList();

          final grouped = <String, List<Map<String, dynamic>>>{};
          for (final item in items) {
            final key = item['time'] as String? ?? '-';
            grouped.putIfAbsent(key, () => <Map<String, dynamic>>[]).add(item);
          }

          final orderedKeys = grouped.keys.toList();
          return orderedKeys
              .map((dateGroup) => {
                    'dateGroup': dateGroup,
                    'items': grouped[dateGroup] ?? const [],
                  })
              .toList();
        } else if (_isDemoSession) {
          _debug('Notifications endpoint returned non-success in demo session, using fallback notifications.');
          return _demoNotificationGroups();
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil notifikasi');
        }
      } else if (response.statusCode == 401 && _isDemoSession) {
        _debug('Notifications endpoint returned 401 in demo session, using fallback notifications.');
        return _demoNotificationGroups();
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('GET', uri, e);
      if (_isDemoSession) {
        return _demoNotificationGroups();
      }
      rethrow;
    }
  }

  Future<int> getUnreadNotificationCount() async {
    final uri = Uri.parse('$baseUrl/notifications/unread-count');
    _logRequest('GET', uri);
    if (_isDemoSession) {
      _debug('Using demo unread notification count fallback.');
      return 4;
    }
    try {
      final response = await http.get(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('GET', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          final data = body['data'] ?? {};
          final count = data['unread_count'];
          if (count is int) return count;
          if (count is String) return int.tryParse(count) ?? 0;
          return 0;
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil jumlah notifikasi');
        }
      } else if (response.statusCode == 401 && _isDemoSession) {
        _debug('Unread-count endpoint returned 401 in demo session, using fallback count.');
        return 4;
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('GET', uri, e);
      if (_isDemoSession) {
        return 4;
      }
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    final uri = Uri.parse('$baseUrl/notifications/$id/read');
    _logRequest('PATCH', uri);
    try {
      final response = await http.patch(uri, headers: _headers);
      _logResponse('PATCH', uri, response.statusCode, body: response.body);

      if (response.statusCode != 200) {
        final Map<String, dynamic> body = _decodeBody(response);
        throw Exception(body['message'] ?? 'Gagal menandai notifikasi dibaca');
      }
    } catch (e) {
      _logError('PATCH', uri, e);
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    final uri = Uri.parse('$baseUrl/notifications/read-all');
    _logRequest('POST', uri);
    try {
      final response = await http.post(uri, headers: _headers);
      _logResponse('POST', uri, response.statusCode, body: response.body);

      if (response.statusCode != 200) {
        final Map<String, dynamic> body = _decodeBody(response);
        throw Exception(body['message'] ?? 'Gagal menandai semua notifikasi dibaca');
      }
    } catch (e) {
      _logError('POST', uri, e);
      rethrow;
    }
  }

  // -----------------------------------------------------------------------------
  // REAL API CALLS: SERVICE REQUESTS
  // -----------------------------------------------------------------------------

  /// Cancel a service request in an allowed status (PATCH)
  Future<ServiceRequest> cancelServiceRequest(String serviceRequestId) async {
    final uri = Uri.parse('$baseUrl/service-requests/$serviceRequestId/cancel');
    _logRequest('PATCH', uri);
    try {
      final response = await http.patch(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('PATCH', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          return ServiceRequest.fromJson(body['data'] ?? const {});
        } else {
          throw Exception(body['message'] ?? 'Gagal membatalkan service request');
        }
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('PATCH', uri, e);
      rethrow;
    }
  }

  /// List status timeline for a service request (GET)
  Future<List<StatusHistory>> getServiceRequestTimeline(String serviceRequestId) async {
    final uri = Uri.parse('$baseUrl/service-requests/$serviceRequestId/timeline');
    _logRequest('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('GET', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          final List<dynamic> data = _extractList(body);
          return data.map((json) => StatusHistory.fromJson(json)).toList();
        } else {
          throw Exception(body['message'] ?? 'Gagal mengambil timeline service request');
        }
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('GET', uri, e);
      rethrow;
    }
  }

  /// Upload attachment to an existing service request (POST multipart)
  Future<Attachment> uploadServiceRequestAttachment(String serviceRequestId, String filePath) async {
    final uri = Uri.parse('$baseUrl/service-requests/$serviceRequestId/attachments');
    _logRequest('POST', uri, body: {'file': filePath});
    try {
      var request = http.MultipartRequest('POST', uri);
      
      if (_cachedToken != null) {
        request.headers['Authorization'] = '$_cachedTokenType $_cachedToken';
      }
      request.headers['Accept'] = 'application/json';
      request.headers['X-Device-Name'] = _getDeviceName();
      request.headers['X-Device-Uuid'] = _getDeviceUuid();

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      _logResponse('POST', uri, response.statusCode, body: response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> body = _decodeBody(response);
        if (body['success'] == true) {
          return Attachment.fromJson(body['data'] ?? const {});
        } else {
          throw Exception(body['message'] ?? 'Gagal mengunggah lampiran');
        }
      } else {
        final Map<String, dynamic> errorBody = _decodeBody(response);
        throw Exception(errorBody['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('POST', uri, e);
      rethrow;
    }
  }

  /// Delete an attachment owned by the tenant service request (DELETE)
  Future<void> deleteServiceRequestAttachment(String serviceRequestId, String attachmentId) async {
    final uri = Uri.parse('$baseUrl/service-requests/$serviceRequestId/attachments/$attachmentId');
    _logRequest('DELETE', uri);
    try {
      final response = await http.delete(uri, headers: _headers);
      final body = _decodeBody(response);
      _logResponse('DELETE', uri, response.statusCode, body: body);

      if (response.statusCode == 200) {
        if (body['success'] != true) {
          throw Exception(body['message'] ?? 'Gagal menghapus lampiran');
        }
      } else {
        throw Exception(body['message'] ?? 'Server error (Kode: ${response.statusCode})');
      }
    } catch (e) {
      _logError('DELETE', uri, e);
      rethrow;
    }
  }

}
