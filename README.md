
1. Project Overview

इस परियोजना का उद्देश्य एक ऐसा मोबाइल एप्लिकेशन बनाना है जो उपयोगकर्ताओं को उनकी मासिक आय और खर्चों का प्रबंधन करने में सहायता करता है। इसमें उपयोगकर्ता Needs (आवश्यकताएँ), Wants (इच्छाएँ) और Savings (बचत) के रूप में अपनी सैलरी को विभाजित कर सकता है। एप्लिकेशन Firebase Firestore का उपयोग कर डेटा स्टोर करता है तथा Firebase Authentication द्वारा लॉगिन/साइनअप की सुविधा भी प्रदान करता है।
 

2. Key Features
क्रमांक	विशेषता	विवरण
1	User Authentication	Firebase द्वारा ईमेल/पासवर्ड लॉगिन एवं साइनअप सुविधा
2	Salary Management	मासिक सैलरी अपडेट और उसका इतिहास सहेजना
3	Expense Categorization	Needs, Wants, Savings में खर्चों का विभाजन
4	Transaction Tracking	प्रत्येक श्रेणी में लेन-देन जोड़ना व देखना
5	Salary History	सभी पुरानी सैलरी रिकॉर्ड्स का संपूर्ण विवरण
6	Responsive UI	मोबाइल व टैबलेट पर समर्थन
7	Real-time Cloud Sync	Firebase Firestore के माध्यम से डेटा सिंक्रोनाइज़ेशन
 
3. Technology Stack


श्रेणी	          तकनीक
Frontend	          Flutter (Dart)
Backend (DB)	          Firebase Firestore
Authentication	          Firebase Auth
Platform Support	          Android (iOS Future)
Dev Tools	          Android Studio


 

4. Project Setup Guide


आवश्यकताएँ:
•	Flutter SDK (संस्करण 3.19+)
•	Dart (संस्करण 3.4+)
•	Android Studio या Visual Studio Code
•	Firebase प्रोजेक्ट (Config)

 
सेटअप प्रक्रिया:
1.	GitHub से कोड क्लोन करें: git clone <repository-url>
2.	Android Studio में प्रोजेक्ट खोलें
3.	flutter pub get चलाएं
4.	google-services.json को /android/app/ में रखें
5.	Firebase Console में Authentication (Email/Password) चालू करें
6.	Firestore में आवश्यक Collections बनाएं
7.	App रन करें: flutter run

 
5. Folder Structure
lib/
│
├── main.dart
├── screens/
│   ├── welcome_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   ├── add_transaction_screen.dart
│   ├── transaction_history_screen.dart
│   ├── salary_history_screen.dart
│   ├── salary_detail_screen.dart
├── services/
│   ├── firebase_service.dart
6. Firebase Firestore Database Design
Users Collection:
Field	Type	विवरण
uid	String	उपयोगकर्ता की ID
email	String	उपयोगकर्ता ईमेल
Salaries Collection:
Field	Type	विवरण
salaryId	String	यूनिक सैलरी ID
uid	String	उपयोगकर्ता ID
amount	Integer	मासिक सैलरी राशि
needs	List	आवश्यक खर्चों की सूची
wants	List	इच्छाओं की सूची
savings	List	बचत की सूची
lastUpdated	Timestamp	अंतिम अद्यतन तारीख
Transactions Collection:
Field				Type					विवरण
transactionId				String					यूनिक लेन-देन ID
salaryId				String					सम्बंधित सैलरी ID
category				String					Needs/Wants/Savings श्रेणी
itemName				String					वस्तु का नाम

									
7. Screen-wise Detailed Explanation
Welcome Screen
•	उद्देश्य: एप्लिकेशन का स्वागत स्क्रीन
•	नेविगेशन: Get Started → Login/Signup
•	विजेट्स: इमेज, बटन
 
Login Screen
•	उद्देश्य: Firebase ईमेल/पासवर्ड लॉगिन
•	विजेट्स: TextFields, Login Button
•	कार्य: Firebase Authentication द्वारा लॉगिन
  
Home Screen
•	उद्देश्य: Needs, Wants, Savings दिखाना
•	नेविगेशन: Add Transaction, Salary History
•	विजेट्स: कार्ड्स, बटन
 
Salary History Screen
•	उद्देश्य: पुरानी सैलरी रिकॉर्ड देखना
•	नेविगेशन: Salary Detail Screen
 
Salary Detail Screen
•	उद्देश्य: चयनित सैलरी का पूर्ण विवरण
•	डेटा: Needs, Wants, Savings, Total Spent, Remaining Balance, Last Updated

Add Transaction Screen
•	उद्देश्य: Needs/Wants/Savings के लिए नया खर्च जोड़ना
•	इनपुट: Category, Item Name, Amount
 
Transaction History Screen
•	उद्देश्य: वर्तमान सैलरी के लेन-देन दिखाना
 

 
8. Application Flow & Navigation
Start → Welcome Screen → (Get Started) → Login/Signup → Home Screen → (Add Transaction | Transaction History | Salary History → Salary Detail)

 
9. Diagrams & Flowcharts
•	Firebase Firestore Data Model Diagram
•	App Navigation Flowchart

 
10. Known Issues & Future Scope
समस्या	समाधान (योजना)
iOS सपोर्ट लंबित है	भविष्य के अपडेट में
वेब/डेस्कटॉप सपोर्ट लंबित है	Flutter Web/Desktop Build

 
11. Appendix: Important Code Snippets
•	Firebase Initialization
•	Firestore Query: Fetch Active Salary
•	Add Transaction Function
•	Update Salary Function
Navigation Code Examples
 
12. Glossary
शब्द	अर्थ
Active Salary	वर्तमान माह की सैलरी रिकॉर्ड
Needs	आवश्यक खर्च (भोजन, किराया आदि)
Wants	वैकल्पिक खर्च (मनोरंजन आदि)
Savings	बचत राशि
Firestore	गूगल का NoSQL क्लाउड डाटाबेस

