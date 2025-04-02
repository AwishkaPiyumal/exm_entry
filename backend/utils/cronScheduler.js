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
        console.log(2, data);
        if (data.length > 0) {
          const dealine = new Date(data[0].endDate)
            .toString()
            .slice(4, new Date(data[0].endDate).toString().indexOf("GMT"));
          const mails = data.map((obj) => obj.email).join(",");

          try {
            await mailer(
              mails,
              `Action Required: Batch ${batch_code} - Your Access is Open`,
              `<p>Now you can access the entry forms of Batch ${batch_code}. your access period will be end on ${dealine}</p>`
            );

            await conn.execute(
              `UPDATE batch_time_periods SET mail_sent = 1 WHERE id = ?`,
              [id]
            );

            console.log(
              `Mail sent to user type ${nextUserType} for batch ${batch_id}`
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
