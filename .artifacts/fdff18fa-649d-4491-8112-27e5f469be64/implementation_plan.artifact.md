# Push Хабарламаларды жақсарту: Badge (счетчик) және Foreground UI

Бұл жоспар iOS/Android иконкаларындағы хабарламалар санын көрсетуді және iOS-та апп ішінде жүргенде хабарламаларды экранға шығаруды іске асырады.

## Негізгі өзгерістер

1.  **Badge басқару**: `flutter_app_badger` арқылы иконкадағы санды Hive-тағы оқылмаған хабарламалар негізінде жаңарту.
2.  **Foreground Notifications**: `flutter_local_notifications` арқылы Android-та "Heads-up" хабарламаларын және iOS-та апп ішіндегі баннерлерді сенімді көрсету.
3.  **Hive интеграциясы**: Хабарлама оқылғанда немесе жойылғанда Badge санын автоматты түрде азайту.

## Ұсынылатын өзгерістер

---

### [Services]

#### [MODIFY] [notification_service.dart](file:///C:/dcplatforma/lib/services/notification_service.dart)
- `flutter_local_notifications` және `flutter_app_badger` инициализациясын қосу.
- `updateBadgeCount()` әдісін енгізу: Hive-тағы `read == false` хабарламаларды санап, иконкаға жазу.
- `onMessage` кезінде `updateBadgeCount()` шақыру.
- `flutter_local_notifications` арқылы iOS-та апп ішінде баннер шығаруды реттеу.

#### [MODIFY] [hive_service.dart](file:///C:/dcplatforma/lib/services/hive_service.dart)
- Оқылмаған хабарламалар санын қайтаратын `getUnreadCount()` әдісін қосу.
- `setNotificationRead` және `deleteNotificationData` әдістері орындалған соң Badge-ді жаңарту логикасын шақыру (немесе сервис арқылы).

### [Screens]

#### [MODIFY] [notifications.dart](file:///C:/dcplatforma/lib/screens/notifications/notifications.dart)
- Бет ашылғанда немесе хабарламалар тізімі өзгергенде Badge-ді нөлге түсіру немесе жаңарту.

---

## Тексеру жоспары

### Автоматты тексеру
- `flutter build ios` және `flutter build apk` арқылы кодтың дұрыстығын тексеру.

### Қолмен тексеру
1.  **Badge**: Хабарлама келгенде иконкада "1", "2" т.б. сандардың пайда болуын тексеру.
2.  **Foreground iOS**: Апп ашық тұрғанда жоғарыдан хабарлама келуін және диалогтың шығуын тексеру.
3.  **Тазалау**: Барлық хабарламаны оқығанда немесе жойғанда иконкадағы санның жоғалып кетуін тексеру.
