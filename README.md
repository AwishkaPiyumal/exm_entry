# EXAM ENTRY SYSTEM

The Examination Entry System is a digital platform designed to streamline university exam registration. It allows students to apply for exams easily, while enabling management and staff to verify eligibility based on attendance and discipline. The system also supports to print the exam addmissions and attendance sheet generation ensuring efficient exam management

## Description

The Examination Entry System is a digital solution designed to streamline the exam registration and verification process in universities and faculties. The system enables students to apply for exams seamlessly while allowing
management to verify eligibility based on attendance records and disciplinary actions. It ensures transparency and efficiency in handling exam applications by integrating a structured approval workflow.

The system categorizes users into five roles: Admin (Head of the Examination Branch), Dean, Head of Department (HOD), Lecturer in Charge, and Students, each with distinct responsibilities to ensure smooth exam management. Students can apply for exams through the system, while the Lecturer inCharge verifies their eligibility based on attendance records. The HOD and Dean can oversees this process, ensuring accuracy and fairness and they can update the eligibility based on key concerns, while the Admin (Head of the Examination Branch) maintains overall system control and print the admission and attendance at the end after all the procedures are done.

Additionally, the system enables Admin to generate attendance sheets based on verified exam entries, reducing administrative workload and errors. By digitizing exam registration, the system minimizes paperwork, reduces ad
ministrative workload, and ensures accuracy in exam-related processes.This scalable and user-friendly platform enhances efficiency, reduces manual errors, and ensures a smooth exam management experience for students and
faculty

## Features

    Student exam application submission
    Eligibility verification by staff (attendance, disciplinary checks)
    Batch-wise exam entry stats for Heads of Departments
    Attendance sheet generation post-verification
    Admin access for record modification and updates
    Secure login for students, staff, HoDs, and admin
    Dashboard for managing and monitoring application status

## Overview of the System

    1.Administrator Operations:
        Create users
        Create batches and curriculums
        Verify/update eligibility
        Insert medical & resit students
        Generate examination admission sheet & attendance sheet
        Generate index numbers for students who do not have them

    2.HOD & Dean Operations
        Update eligibility of students
        View summary report

    3.Lecturer in-charge Operations
        Update eligibility of students

    4.Student Operations
        Apply for examination
        Download Admission. (Temporarily disabled)

### Dependencies

Before installing the system, ensure you have the following software installed on your computer:

1. Node.js(Latest LTS version) – Required for running the frontend and backend.
2. npm(Node Package Manager) – Comes with Node.js.
3. XAMPP/WAMPP
4. phpMyAdmin – (Optional) A graphical interface for MySQL database management
5. Modern Browser

### Executing program

- How to execute the system

  1. To access the system directly ---> https://exm-entry.vercel.app
  2. To locally setup --->  
     i. Download the project from our github repository (https://github.com/SivaramalingamKirushanth/exm_entry)

     ii. Setup Frontend:

     - In the terminal, type "cd frontend"
     - In the terminal, type "npm install"
     - Import .env file with the following properties
       > NEXT_PUBLIC_CRYPTO_SECRET=""
     - Import .env.local file with the following properties
       > BACKEND_SERVER=""  
       > JWT_SECRET=""
     - In the terminal, type "npm run dev"

     iii. Import the database:

     - Download exam_entry.sql file from backend/db/exam_entry.sql
     - Import the file into your MySql database

     iv. Setup Backend:

     - In the terminal, type "cd backend"
     - In the terminal, type "npm install"
     - Import .env file with the following properties

       > DB_HOST=  
       > DB_PORT=  
       > DB_USER=  
       > DB_PASS=  
       > DB_NAME=  

       > PORT=  
       > JWT_SECRET=  
       > EMAIL=  
       > EMAIL_PASS=  

       > FRONTEND_SERVER=  

       > ADMIN_EMAIL=  
       > ADMIN_USERNAME=  
       > ADMIN_PASSWORD=  

     - In the terminal, type "npm run dev"

### Documentation

For detailed project documentation, including the project report and other relevant details, refer to the docs folder.

## Authors

- **2020ICT18**

  - Name: I.M.C Jeewantha
  - Email: chamithjeewa123@gmail.com
  - GitHub: [GitHub Profile](https://github.com/chamithjeewantha)

- **2020ICT24**

  - Name: E.W.A.P Egodawitharana
  - Email: piumal302@gmail.com
  - GitHub: [GitHub Profile](https://github.com/piumal302)

- **2020ICT48**

  - Name: A.I.F Ilma
  - Email: ilmaismail029@gmail.com
  - GitHub: [GitHub Profile](https://github.com/IlmaIsmail)

- **2020ICT57**

  - Name: C.H Hettiarachchi
  - Email: chamathkahettiarachchi@gmail.com
  - GitHub: [GitHub Profile](https://github.com/Chamathka01)

- **2020ICT64**

  - Name: M.I.F Ilma
  - Email: ifilma2001@gmail.com
  - GitHub: [GitHub Profile](https://github.com/Ilmfathima)

- **2020ICT101**

  - Name: A.R Wijesuriya
  - Email: arwijesuriya.7@gmail.com
  - GitHub: [GitHub Profile](https://github.com/arwijesuriya)

- **2020ICT119**
  - Name: L.M Zahran
  - Email: zzzahrannnldeen@gmail.com
  - GitHub: [GitHub Profile](https://github.com/jallu-dev)

## License

MIT License

Copyright (c) 2025 I.M.C Jeewantha,A.I.F Ilma,C.H Hettiarachchi,M.I.F Ilma,A.R Wijesuriya,L.M Zahran

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Acknowledgments

We would like to acknowledge the University of Vavuniya, Faculty of Applied Science, and in particular, our Supervisor Dr. S Kirushanth for his patience and support throughout the project.
