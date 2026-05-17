const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const { DataTypes, Model } = require('sequelize');
const sequelize = require('../config/sequelize');
const UserModel = require('./UserModel');
const { getRefreshTokenExpiration, getRefreshTokenSecret } = require('../config/auth');

function hashToken(token) {
    return crypto.createHash('sha256').update(token).digest('hex');
}

function expirationToDate(expiration) {
    const match = String(expiration).trim().match(/^(\d+)([smhd])$/i);
    if (!match) {
        throw new Error('REFRESH_TOKEN_EXPIRATION must use s, m, h, or d. Example: 30d.');
    }

    const value = Number.parseInt(match[1], 10);
    const unit = match[2].toLowerCase();
    const multipliers = {
        s: 1000,
        m: 60 * 1000,
        h: 60 * 60 * 1000,
        d: 24 * 60 * 60 * 1000
    };

    return new Date(Date.now() + value * multipliers[unit]);
}

class RefreshTokenModel extends Model {
    static async issueForUser(user) {
        const jti = crypto.randomUUID();
        const expiresIn = getRefreshTokenExpiration();
        const token = jwt.sign(
            {
                id: user.id,
                username: user.username,
                role: user.role,
                jti
            },
            getRefreshTokenSecret(),
            { expiresIn }
        );

        await this.create({
            userId: user.id,
            tokenHash: hashToken(token),
            expiresAt: expirationToDate(expiresIn)
        });

        return token;
    }

    static async findValidToken(token) {
        const payload = jwt.verify(token, getRefreshTokenSecret());
        const storedToken = await this.findOne({
            where: {
                tokenHash: hashToken(token),
                revokedAt: null
            },
            include: [{ model: UserModel, as: 'user' }]
        });

        if (!storedToken || storedToken.expiresAt <= new Date() || !storedToken.user) {
            return null;
        }

        if (storedToken.user.id !== payload.id) {
            return null;
        }

        return storedToken;
    }

    static async rotate(token) {
        const storedToken = await this.findValidToken(token);
        if (!storedToken) {
            return null;
        }

        storedToken.revokedAt = new Date();
        await storedToken.save();

        const refreshToken = await this.issueForUser(storedToken.user);
        const accessToken = UserModel.generateAccessToken(storedToken.user);

        return {
            accessToken,
            refreshToken,
            user: storedToken.user
        };
    }

    static async revoke(token) {
        const storedToken = await this.findOne({
            where: {
                tokenHash: hashToken(token),
                revokedAt: null
            }
        });

        if (!storedToken) {
            return false;
        }

        storedToken.revokedAt = new Date();
        await storedToken.save();
        return true;
    }
}

RefreshTokenModel.init(
    {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true
        },
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            field: 'usuario_id',
            references: {
                model: UserModel,
                key: 'id'
            },
            onDelete: 'CASCADE'
        },
        tokenHash: {
            type: DataTypes.STRING(64),
            allowNull: false,
            unique: true,
            field: 'token_hash'
        },
        expiresAt: {
            type: DataTypes.DATE,
            allowNull: false,
            field: 'expires_at'
        },
        revokedAt: {
            type: DataTypes.DATE,
            allowNull: true,
            field: 'revoked_at'
        }
    },
    {
        sequelize,
        modelName: 'RefreshToken',
        tableName: 'RefreshTokens'
    }
);

UserModel.hasMany(RefreshTokenModel, {
    foreignKey: {
        name: 'userId',
        field: 'usuario_id'
    },
    as: 'refreshTokens'
});

RefreshTokenModel.belongsTo(UserModel, {
    foreignKey: {
        name: 'userId',
        field: 'usuario_id'
    },
    as: 'user'
});

module.exports = RefreshTokenModel;
