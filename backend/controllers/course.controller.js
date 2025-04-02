import pool from "../config/db.js";
import errorProvider from "../utils/errorProvider.js";
import { generatePassword, hashPassword } from "../utils/functions.js";
import mailer from "../utils/mailer.js";

export const createFaculty = async (req, res, next) => {
  let { f_name, email, contact_no, status = "true" } = req.body;

  if (!f_name || !email || !contact_no) {
    return next(errorProvider(400, "Missing required fields"));
  }

  try {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      // Step 1: Check if faculty already exists
      const [facultyExistsResult] = await conn.query(
        "CALL CheckIfFacultyExists(?, ?, @exists); SELECT @exists AS faculty_exists;",
        [f_name, email]
      );
      const { faculty_exists } = facultyExistsResult[0];

      if (faculty_exists > 0) {
        conn.release();
        return next(errorProvider(409, "Faculty or email already exists"));
      }

      // Step 2: Generate password and hash it
      const password = await generatePassword();
      const hashedPassword = await hashPassword(password);

      // Step 3: Create the user record
      const [userResult] = await conn.query(
        "CALL CreateFacultyUser(?, ?, @user_id); SELECT @user_id AS user_id;",
        [email, hashedPassword]
      );

      const user_id = userResult[1][0].user_id;

      // Step 4: Create the faculty record
      await conn.query("CALL CreateFaculty(?, ?, ?, ?);", [
        f_name,
        user_id,
        contact_no,
        status,
      ]);

      let desc = `Faculty created with f_name=${f_name}, user_id=${user_id}, email=${email}, contact_no=${contact_no}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

      await mailer(
        email,
        "Registration succesfull",
        `<h2>Faculty registered to examinations</h2>
                <h4>User name : ${email}</h4>
                <h4>Password : ${password}</h4>`
      );
      await conn.commit();

      return res.status(201).json({ message: "Faculty created successfully" });
    } catch (error) {
      await conn.rollback();
      console.error("Error while creating faculty:", error);
      return next(
        errorProvider(500, "An error occurred while creating faculty")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const updateFaculty = async (req, res, next) => {
  const { f_id, f_name, email, contact_no } = req.body;

  if (!f_id || !f_name || !email || !contact_no) {
    return next(errorProvider(400, "Missing required fields"));
  }

  try {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      // Step 1: Check if faculty exists
      const [facultyDetails] = await conn.query(
        "CALL GetFacultyDetailsByFid(?);",
        [f_id]
      );

      if (!facultyDetails[0].length) {
        conn.release();
        return next(errorProvider(404, "Faculty not found"));
      }

      const user_id = facultyDetails[0][0].user_id;

      // Step 2: Update faculty details
      await conn.query("CALL UpdateFacultyDetails(?, ?, ?);", [
        f_id,
        f_name,
        contact_no,
      ]);

      // Step 3: Update user details
      await conn.query("CALL UpdateUserDetails(?, ?);", [user_id, email]);

      let desc = `Faculty updated for f_id=${f_id} with f_name=${f_name}, user_id=${user_id}, email=${email}, contact_no=${contact_no}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

      await conn.commit();

      return res.status(200).json({ message: "Faculty updated successfully" });
    } catch (error) {
      await conn.rollback();
      console.error("Error while updating faculty:", error);
      return next(
        errorProvider(500, "An error occurred while updating faculty")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const updateFacultyStatus = async (req, res, next) => {
  const { id: f_id, status } = req.body;

  if (!f_id || !status) {
    return next(errorProvider(400, "Missing required fields"));
  }

  try {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      // Step 1: Check if faculty exists
      const [facultyDetails] = await conn.query(
        "CALL GetFacultyDetailsByFid(?);",
        [f_id]
      );

      if (!facultyDetails[0].length) {
        conn.release();
        return next(errorProvider(404, "Faculty not found"));
      }

      const user_id = facultyDetails[0][0].user_id;

      // Step 2: Update faculty details
      await conn.query("CALL updateFacultyStatus(?, ?);", [f_id, status]);

      let desc = `Batch status changed for f_id=${f_id} to status=${status}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

      await conn.commit();

      return res
        .status(200)
        .json({ message: "Faculty status updated successfully" });
    } catch (error) {
      await conn.rollback();
      console.error("Error while updating faculty:", error);
      return next(
        errorProvider(500, "An error occurred while updating faculty")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const createDepartment = async (req, res, next) => {
  const { d_name, email, contact_no, status = "true", f_id } = req.body;

  if (!d_name || !email || !contact_no || !f_id) {
    return next(errorProvider(400, "Missing required fields"));
  }

  try {
    const conn = await pool.getConnection();

    try {
      await conn.beginTransaction();

      // Step 1: Check if the department already exists
      const [departmentExistsResult] = await conn.query(
        "CALL CheckIfDepartmentExists(?, ?, @exists); SELECT @exists AS departmentExists;",
        [d_name, email]
      );
      const { departmentExists } = departmentExistsResult[1][0];

      if (departmentExists > 0) {
        conn.release();
        return next(errorProvider(409, "Department already exists"));
      }

      // Step 2: Generate a password and hash it
      const password = await generatePassword();
      const hashedPassword = await hashPassword(password);

      // Step 3: Create a user for the department
      const [userResult] = await conn.query(
        "CALL CreateDepartmentUser(?, ?, @user_id); SELECT @user_id AS user_id;",
        [email, hashedPassword]
      );
      const user_id = userResult[1][0].user_id;

      // Step 4: Create the department
      const [departmentResult] = await conn.query(
        "CALL CreateDepartment(?, ?, ?, ?, @d_id); SELECT @d_id AS d_id;",
        [d_name, user_id, contact_no, status]
      );
      const d_id = departmentResult[1][0].d_id;

      // Step 5: Link the department to the faculty
      await conn.query("CALL LinkFacultyDepartment(?, ?);", [f_id, d_id]);

      let desc = `Department created with d_id=${d_id} for f_id=${f_id}, d_name=${d_name}, user_id=${user_id}, email=${email}, contact_no=${contact_no}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

      // Send email notification to the department user
      await mailer(
        email,
        "Registration succesfull",
        `<h2>Department registered to examinations</h2>
                <h4>User name : ${email}</h4>
                <h4>Password : ${password}</h4>`
      );
      await conn.commit();

      return res.status(201).json({
        message: "Department created successfully",
      });
    } catch (error) {
      await conn.rollback();
      console.error("Error during department creation:", error);
      return next(
        errorProvider(500, "An error occurred while creating department")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const updateDepartment = async (req, res, next) => {
  const { d_id, d_name, email, contact_no, f_id } = req.body;

  if (!d_id || !d_name || !email || !contact_no || !f_id) {
    return next(errorProvider(400, "Missing required fields"));
  }

  try {
    const conn = await pool.getConnection();

    try {
      await conn.beginTransaction();

      // Step 1: Check if department exists
      const [departmentDetails] = await conn.query(
        "CALL GetDepartmentDetailsByDid(?);",
        [d_id]
      );

      if (!departmentDetails[0].length) {
        conn.release();
        return next(errorProvider(404, "Department not found"));
      }

      const user_id = departmentDetails[0][0].user_id;

      // Step 2: Update department details
      await conn.query("CALL UpdateDepartmentDetails(?, ?, ?);", [
        d_id,
        d_name,
        contact_no,
      ]);

      // Step 3: Update user details
      await conn.query("CALL UpdateDepartmentUser(?, ?);", [user_id, email]);

      // Step 4: Update faculty-department link
      await conn.query("CALL UpdateFacultyDepartmentLink(?, ?);", [f_id, d_id]);

      let desc = `Department updated for d_id=${d_id} with d_name=${d_name}, user_id=${user_id}, email=${email}, contact_no=${contact_no}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

      await conn.commit();

      return res
        .status(200)
        .json({ message: "Department updated successfully" });
    } catch (error) {
      await conn.rollback();
      console.error("Error while updating department:", error);
      return next(
        errorProvider(500, "An error occurred while updating department")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const updateDepartmentStatus = async (req, res, next) => {
  const { id: d_id, status } = req.body;

  if (!d_id || !status) {
    return next(errorProvider(400, "Missing required fields"));
  }

  try {
    const conn = await pool.getConnection();

    try {
      await conn.beginTransaction();

      // Step 1: Check if department exists
      const [departmentDetails] = await conn.query(
        "CALL GetDepartmentDetailsByDid(?);",
        [d_id]
      );

      if (!departmentDetails[0].length) {
        conn.release();
        return next(errorProvider(404, "Department not found"));
      }

      const user_id = departmentDetails[0][0].user_id;

      // Step 2: Update department details
      await conn.query("CALL updateDepartmentStatus(?, ?);", [d_id, status]);

      let desc = `Department status changed for d_id=${d_id} to status=${status}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

      await conn.commit();

      return res
        .status(200)
        .json({ message: "Department status updated successfully" });
    } catch (error) {
      await conn.rollback();
      console.error("Error while updating department:", error);
      return next(
        errorProvider(500, "An error occurred while updating department")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const createDegree = async (req, res, next) => {
  const {
    deg_name,
    short,
    levels: levelsArr,
    no_of_sem_per_year,
    status = "true",
    d_id,
  } = req.body;

  const levels = levelsArr.sort((a, b) => a - b).join(":");

  if (!deg_name || !short || !levels || !no_of_sem_per_year || !d_id) {
    return next(errorProvider(400, "Missing required fields"));
  }

  try {
    const conn = await pool.getConnection();

    try {
      await conn.beginTransaction();

      // Step 1: Check if degree already exists
      const [degreeExistsResult] = await conn.query(
        "CALL CheckIfDegreeExists(?, ?, @exists); SELECT @exists AS degree_exists;",
        [deg_name, short]
      );
      const { degree_exists } = degreeExistsResult[1][0];

      if (degree_exists > 0) {
        conn.release();
        return next(errorProvider(409, "Degree already exists"));
      }

      // Step 2: Create the degree
      const [degreeResult] = await conn.query(
        "CALL CreateDegree(?, ?, ?, ?, ?, @deg_id); SELECT @deg_id AS deg_id;",
        [deg_name, short, levels, no_of_sem_per_year, status]
      );
      const deg_id = degreeResult[1][0].deg_id;

      // Step 3: Link the degree with the department
      await conn.query("CALL LinkDegreeWithDepartment(?, ?);", [d_id, deg_id]);

      let desc = `Degree created with deg_id=${deg_id} for d_id=${d_id}, deg_name=${deg_name}, short=${short}, levels=${levels}, no_of_sem_per_year=${no_of_sem_per_year}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

      await conn.commit();

      res.status(201).json({
        message: "Degree added successfully",
        deg_id,
      });
    } catch (error) {
      await conn.rollback();
      console.error("Error during degree creation:", error);
      return next(
        errorProvider(500, "An error occurred while adding the degree")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const updateDegree = async (req, res, next) => {
  const {
    deg_id,
    deg_name,
    short,
    levels: levelsArr,
    no_of_sem_per_year,
    d_id,
  } = req.body;

  const levels = levelsArr.join(":");

  if (
    !deg_id ||
    !deg_name ||
    !short ||
    !levels ||
    !no_of_sem_per_year ||
    !d_id
  ) {
    return next(errorProvider(400, "Missing required fields"));
  }

  try {
    const conn = await pool.getConnection();

    try {
      await conn.beginTransaction();

      // Step 1: Check if degree exists
      const [degreeExistsResult] = await conn.query(
        "CALL GetDegreeDetailsByDegid(?, @exists); SELECT @exists AS degree_exists;",
        [deg_id]
      );
      const { degree_exists } = degreeExistsResult[1][0];

      if (degree_exists === 0) {
        conn.release();
        return next(errorProvider(404, "Degree not found"));
      }

      // Step 2: Check for duplicate degree name or short
      const [duplicateDegreeResult] = await conn.query(
        "CALL CheckForDuplicateDegree(?, ?, ?, @exists); SELECT @exists AS duplicate;",
        [deg_name, short, deg_id]
      );
      const { duplicate } = duplicateDegreeResult[1][0];

      if (duplicate > 0) {
        conn.release();
        return next(errorProvider(409, "Degree already exists"));
      }

      // Step 3: Update degree details
      await conn.query("CALL UpdateDegreeDetails(?, ?, ?, ?, ?);", [
        deg_id,
        deg_name,
        short,
        levels,
        no_of_sem_per_year,
      ]);

      // Step 4: Update department-degree link
      await conn.query("CALL UpdateDepDeg(?, ?);", [d_id, deg_id]);

      let desc = `Degree updated for deg_id=${deg_id} with deg_name=${deg_name}, short=${short}, levels=${levels}, no_of_sem_per_year=${no_of_sem_per_year}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

      await conn.commit();

      return res.status(200).json({ message: "Degree updated successfully" });
    } catch (error) {
      await conn.rollback();
      console.error("Error while updating degree:", error);
      return next(
        errorProvider(500, "An error occurred while updating the degree")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const updateDegreeStatus = async (req, res, next) => {
  const { id: deg_id, status } = req.body;

  if (!deg_id || !status) {
    return next(errorProvider(400, "Missing required fields"));
  }

  try {
    const conn = await pool.getConnection();

    try {
      await conn.beginTransaction();

      // Step 1: Check if degree exists
      const [degreeExistsResult] = await conn.query(
        "CALL GetDegreeDetailsByDegid(?, @exists); SELECT @exists AS degree_exists;",
        [deg_id]
      );
      const { degree_exists } = degreeExistsResult[1][0];

      if (degree_exists === 0) {
        conn.release();
        return next(errorProvider(404, "Degree not found"));
      }

      // Step 3: Update degree details
      await conn.query("CALL updateDegreeStatus(?, ?);", [deg_id, status]);

      let desc = `Degree status changed for deg_id=${deg_id} to status=${status}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

      await conn.commit();

      return res
        .status(200)
        .json({ message: "Degree status updated successfully" });
    } catch (error) {
      await conn.rollback();
      console.error("Error while updating degree:", error);
      return next(
        errorProvider(500, "An error occurred while updating the degree")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getAllFaculties = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query("CALL GetAllFaculties();");
      return res.status(200).json(results[0]); // First result set contains data
    } catch (error) {
      console.error("Error fetching all faculties:", error);
      return next(errorProvider(500, "Failed to fetch all faculties"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getAllFacultiesWithExtraDetails = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query("CALL GetAllFacultiesWithDetails();");
      return res.status(200).json(results[0]); // First result set contains data
    } catch (error) {
      console.error("Error fetching faculties with details:", error);
      return next(errorProvider(500, "Failed to fetch faculties with details"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getFacultyById = async (req, res, next) => {
  const { f_id } = req.body;

  if (!f_id) {
    return next(errorProvider(400, "Missing f_id."));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query("CALL GetFacultyById(?);", [f_id]);

      if (results[0].length === 0) {
        return next(errorProvider(404, `No faculty found for f_id: ${f_id}`));
      }

      return res.status(200).json(results[0][0]); // First result set, first record
    } catch (error) {
      console.error("Error fetching faculty by ID:", error);
      return next(errorProvider(500, "Failed to fetch faculty by ID"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getAllDepartments = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query("CALL GetAllDepartments();");

      if (results[0].length === 0) {
        return next(errorProvider(404, "No departments found."));
      }

      return res.status(200).json({ departments: results[0] }); // First result set contains data
    } catch (error) {
      console.error("Error fetching all departments:", error);
      return next(errorProvider(500, "Failed to fetch all departments"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getAllDepartmentsWithExtraDetails = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query(
        "CALL GetAllDepartmentsWithDetails();"
      );

      return res.status(200).json(results[0]); // First result set contains data
    } catch (error) {
      console.error("Error fetching all departments with details:", error);
      return next(
        errorProvider(500, "Failed to fetch all departments with details")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getDepartmentById = async (req, res, next) => {
  const { d_id } = req.body;

  if (!d_id) {
    return next(errorProvider(400, "Missing d_id."));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query("CALL GetDepartmentById(?);", [d_id]);

      if (results[0].length === 0) {
        return next(
          errorProvider(404, `No department found for d_id: ${d_id}`)
        );
      }

      return res.status(200).json(results[0][0]); // First result set, first record
    } catch (error) {
      console.error("Error fetching department by ID:", error);
      return next(errorProvider(500, "Failed to fetch department by ID"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getAllDegrees = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query("CALL GetAllDegrees();");

      if (results[0].length === 0) {
        return next(errorProvider(404, "No degrees found."));
      }

      return res.status(200).json(results[0]); // First result set contains data
    } catch (error) {
      console.error("Error fetching all degrees:", error);
      return next(errorProvider(500, "Failed to fetch all degrees"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getAllDegreesWithExtraDetails = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query("CALL GetAllDegreesWithDetails();");

      return res.status(200).json(results[0]); // First result set contains data
    } catch (error) {
      console.error("Error fetching degrees with details:", error);
      return next(errorProvider(500, "Failed to fetch degrees with details"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getDegreeById = async (req, res, next) => {
  const { deg_id } = req.body;

  if (!deg_id) {
    return next(errorProvider(400, "Missing deg_id."));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query("CALL GetDegreeById(?);", [deg_id]);

      if (results[0].length === 0) {
        return next(
          errorProvider(404, `No degree found for deg_id: ${deg_id}`)
        );
      }

      return res.status(200).json({
        ...results[0][0],
        levels: results[0][0].levels.split(":"),
      }); // First result set, first record
    } catch (error) {
      console.error("Error fetching degree by ID:", error);
      return next(errorProvider(500, "Failed to fetch degree by ID"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getDegreeByShort = async (req, res, next) => {
  const { short } = req.body;

  if (!short) {
    return next(errorProvider(400, "Missing short."));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query("CALL GetDegreeByShort(?);", [short]);

      if (results[0].length === 0) {
        return next(
          errorProvider(404, `No degree found for degree short: ${short}`)
        );
      }

      return res.status(200).json(results[0][0]); // First result set, first record
    } catch (error) {
      console.error("Error fetching degree by short:", error);
      return next(errorProvider(500, "Failed to fetch degree by short"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getDepartmentsByFacultyId = async (req, res, next) => {
  const { f_id } = req.body;

  if (!f_id) {
    return next(errorProvider(400, "Missing f_id."));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query("CALL GetDepartmentsByFacultyId(?);", [
        f_id,
      ]);

      if (results[0].length === 0) {
        return next(
          errorProvider(404, `No departments found for f_id: ${f_id}`)
        );
      }

      return res.status(200).json(results[0]); // First result set contains data
    } catch (error) {
      console.error("Error fetching departments by f_id:", error);
      return next(errorProvider(500, "Failed to fetch departments by f_id"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getDegreesByDepartmentId = async (req, res, next) => {
  const { d_id } = req.body;

  if (!d_id) {
    return next(errorProvider(400, "Missing d_id."));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query("CALL GetDegreesByDepartmentId(?);", [
        d_id,
      ]);

      if (results[0].length === 0) {
        return next(errorProvider(404, `No degrees found for d_id: ${d_id}`));
      }

      return res.status(200).json(results[0]); // First result set contains data
    } catch (error) {
      console.error("Error fetching degrees by d_id:", error);
      return next(errorProvider(500, "Failed to fetch degrees by d_id"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getNoOfFaculty = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query(
        "CALL GetFacultyCount(@faculty_count); SELECT @faculty_count AS count;"
      );

      const { count } = results[1][0];

      return res.status(200).json({ count });
    } catch (error) {
      console.error("Error retrieving number of faculty:", error);
      return next(
        errorProvider(500, "An error occurred while retrieving faculty count")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getNoOfDepartments = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query(
        "CALL GetDepartmentCount(@department_count); SELECT @department_count AS count;"
      );

      const { count } = results[1][0];

      return res.status(200).json({ count });
    } catch (error) {
      console.error("Error retrieving number of departments:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while retrieving department count"
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getNoOfDegrees = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query(
        "CALL GetDegreeCount(@degree_count); SELECT @degree_count AS count;"
      );

      const { count } = results[1][0];

      return res.status(200).json({ count });
    } catch (error) {
      console.error("Error retrieving number of degrees:", error);
      return next(
        errorProvider(500, "An error occurred while retrieving degree count")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getNoOfDepartmentsByFaculty = async (req, res, next) => {
  const { f_id } = req.params;

  if (!f_id) {
    return res.status(400).json({ message: "Faculty ID is required" });
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query(
        "CALL GetDepartmentCountByFaculty(?, @department_count); SELECT @department_count AS count;",
        [f_id]
      );

      const { count } = results[1][0];

      return res.status(200).json({ count });
    } catch (error) {
      console.error(
        "Error retrieving number of departments by faculty:",
        error
      );
      return next(
        errorProvider(
          500,
          "An error occurred while retrieving department count"
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getNoOfDegreesByDepartment = async (req, res, next) => {
  const { d_id } = req.params;

  if (!d_id) {
    return res
      .status(400)
      .json({ message: "Department ID (d_id) is required" });
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query(
        "CALL GetDegreeCountByDepartment(?, @degree_count); SELECT @degree_count AS count;",
        [d_id]
      );

      const { count } = results[1][0];

      return res.status(200).json({ count });
    } catch (error) {
      console.error("Error retrieving number of degrees by department:", error);
      return next(
        errorProvider(500, "An error occurred while retrieving degree count")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getNoOfDegreesByLevel = async (req, res, next) => {
  const { levels } = req.params;

  if (!levels) {
    return res.status(400).json({ message: "Levels is required" });
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query(
        "CALL GetDegreeCountByLevel(?, @degree_count); SELECT @degree_count AS count;",
        [levels]
      );

      const { count } = results[1][0];

      return res.status(200).json({ count });
    } catch (error) {
      console.error("Error retrieving degree count by levels:", error);
      return next(
        errorProvider(500, "An error occurred while retrieving degree count")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getActiveFacultiesWithDepartmentsCount = async (
  req,
  res,
  next
) => {
  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query(
        "CALL GetActiveFacultiesWithDepartmentsCount();"
      );

      return res.status(200).json(results[0]); // First result set contains data
    } catch (error) {
      console.error(
        "Error fetching active faculties with departments count:",
        error
      );
      return next(
        errorProvider(
          500,
          "Failed to fetch active faculties with departments count"
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getActiveDepartmentsInAFacultyWithDegreesCount = async (
  req,
  res,
  next
) => {
  const { f_id } = req.body;

  if (!f_id) {
    return next(errorProvider(400, "Missing f_id."));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query(
        "CALL GetActiveDepartmentsWithDegreesCount(?);",
        [f_id]
      );

      return res.status(200).json(results[0]); // First result set contains data
    } catch (error) {
      console.error(
        "Error fetching active departments in a faculty with degrees count:",
        error
      );
      return next(
        errorProvider(
          500,
          "Failed to fetch active departments in a faculty with degrees count"
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getActiveDegreesInADepartmentWithLevelsCount = async (
  req,
  res,
  next
) => {
  const { d_id } = req.body;

  if (!d_id) {
    return next(errorProvider(400, "Missing d_id."));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query(
        "CALL GetActiveDegreesInDepartment(?);",
        [d_id]
      );

      return res.status(200).json(results[0]); // First result set contains data
    } catch (error) {
      console.error(
        "Error fetching active degrees in a department with levels count:",
        error
      );
      return next(
        errorProvider(
          500,
          "Failed to fetch active degrees in a department with levels count"
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getAllLevelsInADegree = async (req, res, next) => {
  const { deg_id } = req.body;

  if (!deg_id) {
    return next(errorProvider(400, "Missing deg_id."));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query("CALL GetAllLevelsInDegree(?);", [
        deg_id,
      ]);

      return res.status(200).json(results[0]); // First result set contains data
    } catch (error) {
      console.error("Error fetching levels in a degree:", error);
      return next(errorProvider(500, "Failed to fetch levels in a degree"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};
