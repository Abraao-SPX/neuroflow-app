const nodemailer = require('nodemailer');

function getMailConfig() {
    return {
        host: process.env.MAIL_HOST || 'smtp.gmail.com',
        port: Number(process.env.MAIL_PORT || 587),
        secure: process.env.MAIL_SECURE === 'true',
        user: process.env.MAIL_USER,
        pass: process.env.MAIL_PASS,
        from: process.env.MAIL_FROM || process.env.MAIL_USER
    };
}

function isMailConfigured() {
    const config = getMailConfig();
    return Boolean(config.user && config.pass && config.from);
}

function createTransporter() {
    const config = getMailConfig();

    return nodemailer.createTransport({
        host: config.host,
        port: config.port,
        secure: config.secure,
        auth: {
            user: config.user,
            pass: config.pass
        }
    });
}

function escapeHtml(value) {
    return String(value)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

async function sendPasswordResetEmail({ to, token, expires }) {
    if (!isMailConfigured()) {
        return false;
    }

    const config = getMailConfig();
    const expiresAt = expires.toLocaleString('pt-BR', {
        dateStyle: 'short',
        timeStyle: 'short'
    });

    await createTransporter().sendMail({
        from: config.from,
        to,
        subject: 'Recuperacao de senha - NeuroFlow',
        text: [
            'Voce solicitou a recuperacao de senha no NeuroFlow.',
            '',
            `Codigo de recuperacao: ${token}`,
            `Valido ate: ${expiresAt}`,
            '',
            'Se voce nao solicitou essa recuperacao, ignore este email.'
        ].join('\n'),
        html: `
            <p>Voce solicitou a recuperacao de senha no NeuroFlow.</p>
            <p><strong>Codigo de recuperacao:</strong></p>
            <p style="font-size: 28px; letter-spacing: 6px;"><strong>${token}</strong></p>
            <p><strong>Valido ate:</strong> ${expiresAt}</p>
            <p>Se voce nao solicitou essa recuperacao, ignore este email.</p>
        `
    });

    return true;
}

async function sendParentVerificationEmail({ to, childName, code, expires }) {
    if (!isMailConfigured()) {
        return false;
    }

    const config = getMailConfig();
    const expiresAt = expires.toLocaleString('pt-BR', {
        dateStyle: 'short',
        timeStyle: 'short'
    });
    const safeChildName = escapeHtml(childName);

    await createTransporter().sendMail({
        from: config.from,
        to,
        subject: 'Codigo de acesso dos responsaveis - NeuroFlow',
        text: [
            `Voce foi convidado para acompanhar ${childName} no NeuroFlow.`,
            '',
            `Codigo de verificacao: ${code}`,
            `Valido ate: ${expiresAt}`,
            '',
            'Depois de validar o codigo, voce podera criar sua senha e entrar com este e-mail.'
        ].join('\n'),
        html: `
            <p>Voce foi convidado para acompanhar <strong>${safeChildName}</strong> no NeuroFlow.</p>
            <p><strong>Codigo de verificacao:</strong></p>
            <p style="font-size: 28px; letter-spacing: 6px;"><strong>${code}</strong></p>
            <p><strong>Valido ate:</strong> ${expiresAt}</p>
            <p>Depois de validar o codigo, voce podera criar sua senha e entrar com este e-mail.</p>
        `
    });

    return true;
}

module.exports = {
    isMailConfigured,
    sendParentVerificationEmail,
    sendPasswordResetEmail
};
