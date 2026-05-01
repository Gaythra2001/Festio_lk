export const verfiyAdmin = (req, res, next) => {
    if (!req.user.isAdmin) {
        return res.status(403).json({ success: false, message: 'Access denied. Only admin are allowed.' });
    }
    next();
};