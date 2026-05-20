const buckets = new Map();

function getClientIp(req) {
    const forwardedFor = req.headers['x-forwarded-for'];
    if (typeof forwardedFor === 'string' && forwardedFor.trim()) {
        return forwardedFor.split(',')[0].trim();
    }

    return req.ip || req.socket?.remoteAddress || 'unknown';
}

function createRateLimiter({ windowMs, max, message }) {
    if (!windowMs || !max) {
        throw new Error('Rate limiter requires windowMs and max.');
    }

    return (req, res, next) => {
        if (process.env.RATE_LIMIT_DISABLED === 'true') {
            return next();
        }

        const now = Date.now();
        const key = `${req.method}:${req.originalUrl.split('?')[0]}:${getClientIp(req)}`;
        const current = buckets.get(key);

        if (!current || current.resetAt <= now) {
            buckets.set(key, {
                count: 1,
                resetAt: now + windowMs
            });
            return next();
        }

        current.count += 1;
        if (current.count > max) {
            const retryAfterSeconds = Math.ceil((current.resetAt - now) / 1000);
            res.set('Retry-After', String(retryAfterSeconds));
            return res.status(429).json({
                success: false,
                message: message || 'Muitas tentativas. Tente novamente mais tarde.'
            });
        }

        return next();
    };
}

setInterval(() => {
    const now = Date.now();
    for (const [key, bucket] of buckets.entries()) {
        if (bucket.resetAt <= now) {
            buckets.delete(key);
        }
    }
}, 10 * 60 * 1000).unref();

module.exports = createRateLimiter;
