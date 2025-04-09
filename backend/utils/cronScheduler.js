import pool from "../config/db.js";
import { fetchEmailsForUserType } from "./functions.js";
import mailer from "./mailer.js";
import cron from "node-cron";

const USER_TYPE_FLOW = { 5: "4", 4: "3", 3: "2" };

export const sendBatchNotifications = async () => {
  try {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      const [rows] = await conn.execute(
        `SELECT btp.*, b.batch_code 
         FROM batch_time_periods btp 
         JOIN batch b ON btp.batch_id = b.batch_id 
         WHERE (btp.end_date <= NOW() AND btp.mail_sent = 0 AND btp.user_type != '2' AND btp.user_type != '5') OR (b.application_open < NOW() AND btp.mail_sent = 0 AND user_type = '5')`
      );

      for (const row of rows) {
        const { batch_id, user_type, id, batch_code } = row;

        const nextUserType = USER_TYPE_FLOW[user_type];

        if (!nextUserType) continue;

        const data = await fetchEmailsForUserType(conn, batch_id, nextUserType);

        if (data.length > 0) {
          const dealine = new Date(data[0].endDate)
            .toString()
            .slice(4, new Date(data[0].endDate).toString().indexOf("GMT"));
          const mails = data.map((obj) => obj.email).join(",");

          try {
            await mailer(
              mails,
              `Action Required: Batch ${batch_code} - Access Now Available`,
              `
              <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 10px;">
                <h2 style="color: #2c3e50;">🔓 Access Granted</h2>
            
                <p>Dear Academic Staff,</p>
            
                <p>You have been granted access to manage student eligibility details for <strong>Batch ${batch_code}</strong>. Please ensure that all relevant changes are completed before the deadline.</p>
            
                <p><strong>Access Deadline:</strong> ${deadline}</p>
            
                <p>During this period, you may:</p>
                <ul>
                  <li>Review Applied Students</li>
                  <li>Update Eligibility Status</li>
                </ul>
            
                <p>If you have any questions or encounter issues, please contact the Examination Branch at 
                  <a href="mailto:${process.env.ADMIN_EMAIL}">${process.env.ADMIN_EMAIL}</a>.
                </p>
            
                <p style="margin-top: 30px;">Thank you for your cooperation.<br/>Examination Branch</p>
              </div>
              `
            );

            await conn.execute(
              `UPDATE batch_time_periods SET mail_sent = 1 WHERE id = ?`,
              [id]
            );
          } catch (mailError) {
            console.error(
              `Failed to send mail for batch ${batch_id}:`,
              mailError
            );
          }
        }
      }

      await conn.commit();
    } catch (error) {
      console.error("Error in cron job:", error);
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
  }
};

cron.schedule("5 */1 * * *", sendBatchNotifications);
