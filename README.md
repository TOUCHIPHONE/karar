# Karar Manager

تطبيق Flutter لإدارة أجور العمال والمصروفات مع تكامل Firebase للمصادقة والتخزين السحابي.

## المميزات
- تسجيل دخول كمدير أو عامل.
- لوحة تحكم للمدير لإضافة أعمال، مصروفات، تصفية وبحث وطباعة (يمكن ربطه لاحقاً بخدمة الطباعة).
- إدارة حسابات العمال والمديرين وتعديل البيانات وتغيير كلمة المرور.
- واجهة عامل لعرض الحقوق اليومية وإرسال ملاحظات للمدير.
- دعم الوضع الليلي والنهاري وتصميم حديث متعدد البطاقات.

## المتطلبات
1. تثبيت Flutter وDart SDK.
2. إنشاء مشروع Firebase وتفعيل Authentication (Email/Password) وخدمة Cloud Firestore.
3. تنزيل ملفات `google-services.json` و `GoogleService-Info.plist` وربطها بالمشروع.
4. تحديث ملف `lib/firebase_options.dart` بقيم مفاتيح Firebase الخاصة بك.

## تشغيل التطبيق
```bash
flutter pub get
flutter run
```

## بنية البيانات المقترحة في Firestore
```
workers (collection)
  └── {workerId}
        fullName: string
        email: string
        phone: string
        avatarUrl: string
        hourlyRate: number
        role: worker | manager | admin | superAdmin

wages (collection)
  └── {wageId}
        workerId: string
        workerName: string
        partType: string
        piecesCount: number
        pricePerPiece: number
        totalAmount: number
        date: ISO8601 string
        notes: string

expenses (collection)
  └── {expenseId}
        title: string
        amount: number
        date: ISO8601 string
        createdBy: workerId
        notes: string
```

## ملاحظات
- الكود يحتوي على نقاط TODO لدمج التنبيهات أو الطباعة عبر خدمات إضافية.
- يوصى بإضافة فحص صلاحيات Firebase Security Rules لتقييد الوصول حسب دور المستخدم.
- يمكن توسيع التصميم بإضافة حزم مثل `fl_chart` لعرض الرسوم البيانية أو `printing` للطباعة.
