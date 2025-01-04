import pool from "../config/db.js";
import errorProvider from "../utils/errorProvider.js";

export const applyExam = async (req, res, next) => {
  const { user_id } = req.user;

  if (!user_id) {
    return next(errorProvider(400, "User ID is required."));
  }

  try {
    const conn = await pool.getConnection();
    try {
      const [result] = await conn.query("CALL ApplyExam(?);", [user_id]);

      return res.status(200).json({
        message: "Exam application processed successfully.",
      });
    } catch (error) {
      console.error("Error during exam application:", error);

      if (error.code === "45000") {
        return next(errorProvider(400, error.sqlMessage));
      }

      return next(
        errorProvider(
          500,
          "An error occurred while processing the exam application."
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection."));
  }
};

export const addMedicalResitStudents = async (req, res, next) => {
  const { data, batch_id } = req.body;

  if (!data || !batch_id) {
    return res
      .status(400)
      .json({ message: "Transformed data and batch_id are required." });
  }

  try {
    const conn = await pool.getConnection();
    try {
      for (const [sub_id, students] of Object.entries(data)) {
        for (const { s_id, type } of students) {
          await conn.query("CALL AddMedicalResitStudents(?, ?, ?, ?)", [
            batch_id,
            sub_id,
            s_id,
            type,
          ]);
        }
      }

      return res.status(200).json({ message: "Students added successfully." });
    } catch (error) {
      console.error("Error adding medical/resit students:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while adding medical/resit students."
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection."));
  }
};

export const getStudentSubjects = async (req, res, next) => {
  const { batch_id, s_id } = req.body;
  console.log(batch_id, s_id);
  try {
    const conn = await pool.getConnection();
    try {
      const [results] = await conn.query("CALL GetStudentSubjects(?, ?);", [
        batch_id,
        s_id,
      ]);
      console.log(results);
      return res.status(200).json(results[0]);
    } catch (error) {
      console.error("Error fetching student subjects:", error);
      return next(
        errorProvider(500, "An error occurred while fetching student subjects.")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection."));
  }
};

export const getStudentsWithoutIndexNumber = async (req, res, next) => {
  const { batch_id } = req.body;

  if (!batch_id) {
    return res.status(400).json({ message: "Batch ID is required." });
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query(
        "CALL GetStudentsWithoutIndexNumber(?);",
        [batch_id]
      );
      console.log(results[1]);
      const count = results[0][0]?.students_without_index || 0;
      const user_names = results[1]?.map((obj) => obj.user_name);
      return res.status(200).json({
        count,
        user_names,
      });
    } catch (error) {
      console.error("Error fetching students without index number:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while checking students without index numbers."
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection."));
  }
};

export const generateIndexNumbers = async (req, res, next) => {
  const { batch_id, course, batch, startsFrom } = req.body;

  if (!batch_id || !course || !batch || !startsFrom) {
    return res.status(400).json({ message: "All fields are required." });
  }

  try {
    const conn = await pool.getConnection();
    try {
      const [results] = await conn.query(
        "CALL GenerateIndexNumbers(?, ?, ?, ?);",
        [batch_id, course, batch, parseInt(startsFrom, 10)]
      );
      console.log(results);
      return res.status(200).json({
        message: "Index numbers generated successfully.",
        data: results[0], // List of updated students
      });
    } catch (error) {
      console.error("Error generating index numbers:", error);
      return next(
        errorProvider(500, "An error occurred while generating index numbers.")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection."));
  }
};

export const getLastAssignedIndexNumber = async (req, res, next) => {
  const { course, batch } = req.body;
  console.log(req.body);
  if (!course || !batch) {
    return next(errorProvider(400, "Course and batch are required."));
  }

  try {
    const conn = await pool.getConnection();
    try {
      const [results] = await conn.query(
        "CALL GetLastAssignedIndexNumber(?, ?);",
        [course, batch]
      );

      let lastIndex = results[0][0]?.last_assigned_index || 0;
      lastIndex = lastIndex ? Number(String(lastIndex).slice(2)) : 0;

      return res.status(200).json({
        lastIndex,
      });
    } catch (error) {
      console.error("Error fetching last assigned index number:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while fetching the last assigned index number."
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection."));
  }
};

export const createOrUpdateAdmission = async (req, res, next) => {
  const {
    batch_id,
    generated_date,
    subjects,
    date,
    description,
    instructions,
  } = req.body;

  try {
    // Transform `subjects` array
    const transformedSubjects = subjects
      .map((subjectArray) => subjectArray.join(":"))
      .join(",");

    // Transform `date` array
    const transformedDate = date
      .map((dateObj) => `${dateObj.year}:${dateObj.months.join(";")}`)
      .join(",");

    // Database connection and procedure execution
    const conn = await pool.getConnection();
    try {
      await conn.query("CALL updateAdmissionData(?, ?, ?, ?, ?, ?)", [
        batch_id,
        generated_date,
        transformedSubjects,
        transformedDate,
        description,
        instructions,
      ]);

      return res.status(200).json({
        message: "Admission data added or updated successfully.",
      });
    } catch (error) {
      console.error("Error adding or updating admission data:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while adding or updating admission data."
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection."));
  }
};

export const getLatestAdmissionTemplate = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();

    // Call the stored procedure
    const [rows] = await conn.query("CALL getLatestAdmissionTemplate()");

    if (rows.length === 0) {
      return res.status(404).json({
        message: "No admission template found.",
      });
    }

    // Respond with the description and instructions
    const { description, instructions } = rows[0][0];
    return res.status(200).json({
      description,
      instructions,
    });
  } catch (error) {
    console.error("Error fetching latest admission template:", error);
    return next(
      errorProvider(
        500,
        "An error occurred while fetching the latest admission template."
      )
    );
  }
};

export const fetchStudentsWithSubjects = async (req, res, next) => {
  const { batch_id } = req.body;

  try {
    const conn = await pool.getConnection();
    try {
      const [results] = await conn.query("CALL FetchStudentsWithSubjects(?);", [
        batch_id,
      ]);

      // Format the result as an object with P, M, and R groups
      const groupedResults = { P: [], M: [], R: [] };

      results[0].forEach((row) => {
        const {
          s_id,
          name,
          index_num,
          user_name,
          exam_type,
          sub_id,
          eligibility,
        } = row;

        // Determine the group based on exam_type
        const group = groupedResults[exam_type];

        // Check if student already exists in the group
        let student = group.find((student) => student.s_id === s_id);

        if (!student) {
          student = {
            s_id,
            name,
            index_num,
            user_name,
            subjects: [],
          };
          group.push(student);
        }

        // Add subject to the student's subjects array
        student.subjects.push({ sub_id, eligibility });
      });

      // Sort each group by lexicographical order of index_num
      Object.keys(groupedResults).forEach((key) => {
        groupedResults[key].sort((a, b) =>
          a.index_num.localeCompare(b.index_num)
        );
      });

      res.status(200).json(groupedResults);
    } catch (error) {
      console.error("Error fetching students with subjects:", error);
      return next(
        errorProvider(500, "An error occurred while fetching students.")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection."));
  }
};
