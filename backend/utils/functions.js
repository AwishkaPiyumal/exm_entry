import crypto from "crypto";
import bcrypt from "bcrypt";

export const generatePassword = async (length = 12) => {
  return crypto.randomBytes(length).toString("base64").slice(0, length);
};

export const hashPassword = async (password) => {
  const hashedPassword = await bcrypt.hash(password, 10);
  return hashedPassword;
};

export const verifyPassword = async (password, hashedPassword) => {
  try {
    return await bcrypt.compare(password, hashedPassword);
  } catch (error) {
    console.error("Error verifying password:", error);
    throw new Error("Password verification failed");
  }
};

export function parseString(input) {
  const regex = /^(\d{4})([A-Za-z()]+)(\d)(\d)$/;
  const match = input.match(regex);

  if (match) {
    const academic_year = match[1];
    const degree_name_short = match[2];
    const level = match[3];
    const sem_no = match[4];

    return {
      academic_year,
      degree_name_short,
      level,
      sem_no,
      batch_code: input,
    };
  } else {
    throw new Error("Invalid format");
  }
}

export function shallowCompare(obj1, obj2) {
  if (Object.keys(obj1).length !== Object.keys(obj2).length) {
    return false;
  }

  for (let key in obj1) {
    if (obj1[key] !== obj2[key]) {
      return false;
    }
  }
  return true;
}

export const fetchEmailsForUserType = async (conn, batchId, userType) => {
  try {
    let query;
    let values;

    if (userType === "4") {
      query = `SELECT u.email, btp.end_date, btp.id FROM batch_curriculum_lecturer bcl
               JOIN manager m ON bcl.m_id = m.m_id
               JOIN user u ON m.user_id = u.user_id
               JOIN batch_time_periods btp ON btp.batch_id = bcl.batch_id
               WHERE bcl.batch_id = ? AND btp.user_type = ?`;
      values = [batchId, userType];
    } else if (userType === "3") {
      query = `SELECT u.email, btp.end_date, btp.id FROM batch b
               JOIN dep_deg dd ON b.deg_id = dd.deg_id
               JOIN department d ON dd.d_id = d.d_id
               JOIN user u ON d.user_id = u.user_id
                JOIN batch_time_periods btp ON btp.batch_id = b.batch_id
               WHERE b.batch_id = ? AND btp.user_type = ?`;
      values = [batchId, userType];
    } else if (userType === "2") {
      query = `SELECT u.email, btp.end_date, btp.id FROM batch b
               JOIN dep_deg dd ON b.deg_id = dd.deg_id
               JOIN fac_dep fd ON dd.d_id = fd.d_id
               JOIN faculty f ON fd.f_id = f.f_id
               JOIN user u ON f.user_id = u.user_id
                JOIN batch_time_periods btp ON btp.batch_id = b.batch_id
               WHERE b.batch_id = ? AND btp.user_type = ?`;
      values = [batchId, userType];
    } else {
      return [];
    }

    const [rows] = await conn.execute(query, values);
    return rows.map((row) => ({
      email: row.email,
      id: row.id,
      endDate: row.end_date,
    }));
  } catch (error) {
    console.error("Error fetching emails:", error);
    return [];
  }
};
