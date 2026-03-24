# 🎓 Student Grade Calculator System (Dart)

## 🎯 Objective

The goal of this project is to develop a system that:

- Reads student data from an Excel file
- Automatically calculates grades
- Displays results (Console + GUI)
- Exports processed results back to Excel

---

## 📌 Problem Statement

Manual grading is:

- Time-consuming
- Prone to errors
- Inefficient

This project automates the grading process to improve accuracy and efficiency.

---

## 🏗️ System Architecture

The system follows a **modular structure**:

- **Presentation Layer**

  - Console Interface
  - Flutter GUI

- **Business Logic Layer**

  - Grade calculation

- **Service Layer**

  - Excel file handling

- **Model Layer**
  - Student data representation

---

## 🧩 Key Components

### 📌 Student Model

Represents a student with:

- Name
- Course
- Exam Mark
- Grade

---

### 📌 Calculator (Abstract Class)

Defines the structure for calculations:

- `calculate()`
- `calculateAll()`
- `validateInput()`

---

### 📌 Grade Calculator

- Assigns grades (A–F)
- Processes multiple students
- Calculates averages and distributions

---

### 📌 Excel Service

- Reads student data from Excel
- Writes processed results back

---

### 📌 State Management

Handles:

- Loading
- Success
- Error

---

### 📌 User Interfaces

#### 🖥️ Console Mode

- Displays results in terminal

#### 🎨 GUI Mode (Flutter)

- File picker
- Process button
- Results table
- Export functionality

---

## ⚙️ System Workflow

1. Select Excel file
2. Read student data
3. Validate input
4. Calculate grades
5. Display results
6. Export results

---

## 💡 Key Features

- 📊 Automatic grade calculation
- 📂 Excel import/export
- 🖥️ Console and GUI support
- 📈 Grade statistics
- ⚡ Efficient data processing

---

## 🧠 Technologies Used

- **Dart**
- **Flutter**
- **Excel libraries**

---

## 🧪 Key Concepts Applied

- **Object-Oriented Programming (OOP)**
- **Abstraction & Inheritance**
- **Encapsulation & Polymorphism**
- **Functional Programming (map, where, fold)**
- **Null Safety**
- **State Management**
- **File Handling**
- **UI & Backend Separation**

---

## 📊 Advantages

- Saves time
- Reduces errors
- Easy to use
- Scalable design

---

## ⚠️ Limitations

- Depends on Excel format
- No database integration
- No authentication system

---

## 🚀 Future Improvements

- Add database (Firebase/MySQL)
- Implement user authentication
- Deploy as web/mobile app
- Add analytics dashboard

---

## 📌 Conclusion

This project successfully automates student grading while demonstrating strong software engineering principles such as modular design, OOP, and clean architecture.

---
