# ProiectIngSwt
<img width="1064" height="724" alt="Screenshot 2025-11-20 205336" src="https://github.com/user-attachments/assets/f42aae8f-7e4e-41a2-b066-39a02399ed14" />

## Description
This is a Jakarta EE project that manages internship applications, student and company information. It uses:

- Jakarta EE / JPA for persistence
- MySQL database
- JDBC Connection Pool and Resources
- Entities: Attachment, CompanyInfo, StudentInfo, UserAccount, Sess, AccountActivity, InternshipPosition, InternshipApplication, Permission

---

## Project Setup

1. **Database**
   - Create the database `ProiectIngSwt`.
   - Use the provided SQL schema to create tables.

2. **JDBC Resource & Connection Pool**
   - Configure your application server (GlassFish / Payara) to connect to `ProiectIngSwt` database.
   - Example JNDI: `jdbc/ProiectIngSwtPool`.

3. **Persistence**
   - Make sure `persistence.xml` is in `src/main/resources/META-INF/`.
   - The persistence unit uses the JNDI datasource.

4. **Entities**
   - All JPA entities are under `org.proiect.IngSwt.JPAEntities`.

---

## Running Tests

- A simple test class (`TestPersistence.java`) is provided to check entity generation and persistence.
- Compile and run the test to verify database connection and table creation.

---

## Entities Overview

- **Attachment**: Stores CV and profile pictures as BLOBs.
- **CompanyInfo**: Company data, optional attachment, JSON fields for positions and students applied.
- **StudentInfo**: Student details, attachment, ENUM status, tinyint `enrolled`.
- **UserAccount**: Links to CompanyInfo or StudentInfo.
- **Sess**: Tracks user logins and tokens.
- **AccountActivity**: Logs user actions with old/new data.
- **InternshipPosition**: Positions offered by companies.
- **InternshipApplication**: Applications by students to positions.
- **Permission**: Role of a user (Faculty, Student, Company).

---

## Notes

- JSON fields are stored as `String` in entities; serialization/deserialization is handled manually or via converters.
- LOB fields (`BLOB`) are mapped with `@Lob`.
- Enumerated fields use `@Enumerated(EnumType.STRING)`.

---

## Author

Your Name
