import jwt from "jsonwebtoken";
import errorProvider from "./errorProvider.js";

export const verifyUser = (allowedRoles) => (req, res, next) => {
  const token = req.cookies["access-token"];
  //check is there any token exists
  if (!token) return next(errorProvider(401, "Unauthorized"));
  try {
    //verify the token and return raw data(_id)
    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
      if (err) {
        return next(errorProvider(403, "Forbidden"));
      }

      if (!allowedRoles.includes(user.role_id)) {
        return res.status(403).json({ message: "Forbidden" });
      }

      req.user = user;
      next();
    });
  } catch (err) {
    return res.status(401).json({ message: "Unauthorized" });
  }
};
