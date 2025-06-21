[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-718a45dd9cf7e7f842a935f5ebbe5719a5e09af4491e668f4dbf3b35d5cca122.svg)](https://classroom.github.com/online_ide?assignment_repo_id=12095445&assignment_repo_type=AssignmentRepo)

# 🏠 Shared Household Inventory App

A cross-platform mobile app built with **Flutter** and **Firebase** for managing personal and shared inventory in co-living environments.

This app helps roommates and shared households track ownership, usage, and storage of items—supporting features like item sharing, real-time sync, image-based entry, and QR-based user pairing.

This is a team final project for CS5520 at Northeastern University.

## 🚀 Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend/Services**: Firebase Firestore, Firebase Authentication, Firebase Storage
- **Other Tools**: Google ML Kit (image recognition), QR Code API, GitHub Projects (project management)


## 🧩 Key Features

- **User Registration and Household Hosting**
  - Secure login and registration
  - Role-based access control: Admin/Host vs Member

- **Private Inventory ("My Stuff")**
  - Add items with descriptions, images, and purchase info
  - Filter by room/location
  - Share items to household inventory

- **Household Inventory ("My House")**
  - Shared view of contributed items from all members
  - Admin controls and owner-based item permissions
  - Real-time syncing across devices

- **QR Code-Based Onboarding**
  - Seamless user pairing to household via time-sensitive QR invites

- **ML-Based Item Entry**
  - Google ML Kit integration for photo-based item detection *(beta feature)*

- **Performance & Testing**
  - Over 75% unit test coverage on core services
  - Optimized UI for mobile responsiveness
  - Real-time updates via Firestore listeners


## 🛠 Architecture Overview

- **Modular Firebase service abstraction**
- **Firestore data modeling** based on users, households, and item ownership
- **Scoped state management** to isolate data across tabs
- **Widget reusability** and mobile-first UX design


## App Workflow Overview

The app is organized into three main segments accessible from a bottom navigation bar:

1. **My Stuff** – User's personal inventory  
![App Workflow Diagram My Stuff](/documentation/AppFlow_MyStuff_Final.png) 

2. **My House** – Shared household items 
![App Workflow Diagram, My House](/documentation/AppFlow_MyHouse_Final.png) 

3. **My Profile** – Account settings and user management 
![App Workflow Diagram, My Profile](/documentation/AppFlow_MyProfile_Final.png)  

---

## Key Wireframes  

**Login & Create Account**  
![Hi-Fi Wireframe Login and Create Account Page](/documentation/HFWF_Login_CreateAccount.png)  

**My Stuff Page**

![Hi-Fi Wireframe My Stuff Page](/documentation/HFWF_MyStuff.png)  

**Add Item Page**

![Hi-Fi Wireframe Add Item Page](/documentation/HFWF_AddItem.png)  

**Edit Item Details Page**

![Hi-Fi Wireframe Edit Item Page](/documentation/HFWF_EditItem.png)  

**Household Creating, Paring, and Invitation Pages**

![Hi-Fi Wireframe Create, Join, and Invite to House Pages](/documentation/HFWF_CreateJoinInviteHouse.png)  


## UML Class Diagram  

```mermaid
classDiagram
    class IndividualItem {
        +fetchItemData()
        +deleteItem()
        +transferItemToHouse()
        +editItem
    }
    class HouseItem {
        +checkOwnership()
        +fetchHouseItemData()
        +deleteHouseItem()
    }
    class Item {
        -String id
        -String name
        -String brand
        -String dateAdded
        -String image
        -String location
        -String notes
        -String owner
        -String ownerFullName
        -String price
        -String purchaseMethod
        -String purchasedAt
        -String purchaseDate
        -String reciept
    }
    class House {
        -String id
        -User Admin
        -Array[User] Member
        -Collection[Item] HouseItems
        +getHouseMember()
        +createHousehold()
        +addUserToHousehold()
        +getAdmin()
        +getMembers()
        +getHouseItems()
        +fetchMemberData(userId)
    }  
    class User {
        -String id
        -String firstName
        -String lastName
        -String email
        -String password
        -Collection[Item] MyStuff
        -Collection[House] MyHouse
        +fetchUserData()
        +getMyStuff()
        +getMyHouse()
        +addItem()
    }
    House "1" --> "0..*" HouseItem
    House "0..1"<-->"1..*" User
    User "1"-->"0..*" IndividualItem
    IndividualItem --|> Item
    HouseItem --|> Item
```

## Gantt Chart  

Visual timeline for our team’s development cycle (Waterfall style)

![Project Final Gantt Chart](documentation/AvengersGanttChart_Final.png)  


## 🗂 Project Status

✅ Finalized core features  
🧪 In progress: improved ML integration, item export features  
🧱 Full-cycle development completed using waterfall-style planning and milestone tracking via GitHub Projects


## 👥 Team

Developed by: Andrew Moran, Jiyu He, Kabila Williams, Steve Chen  
Final project for CS5520 - Mobile App Development, Northeastern University

## 🔗 License

MIT License (or as applicable)

