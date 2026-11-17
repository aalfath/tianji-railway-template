// Tianji's first migration seeds a user "admin" with the password "admin".
// On every start, if that user still has the default password, replace it
// with ADMIN_PASSWORD. A password the admin has changed is never touched.
import pg from 'pg';
import bcrypt from 'bcryptjs';

const password = process.env.ADMIN_PASSWORD;
if (!password) {
  console.log('[railway] ADMIN_PASSWORD is not set; admin password left unchanged');
  process.exit(0);
}
if (password === 'admin' || password.length < 12) {
  console.error('[railway] ADMIN_PASSWORD must be at least 12 characters and not "admin"');
  process.exit(1);
}

const client = new pg.Client({ connectionString: process.env.DATABASE_URL });
await client.connect();
try {
  const { rows } = await client.query(
    `SELECT id, password FROM "User" WHERE username = 'admin' AND "deletedAt" IS NULL`
  );
  for (const user of rows) {
    if (user.password && (await bcrypt.compare('admin', user.password))) {
      await client.query(
        `UPDATE "User" SET password = $1, "updatedAt" = now() WHERE id = $2`,
        [await bcrypt.hash(password, 10), user.id]
      );
      console.log('[railway] replaced the default admin password with ADMIN_PASSWORD');
    }
  }
} finally {
  await client.end();
}
