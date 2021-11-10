export default async function $(...args: string[]) {
  const proc = Deno.run({
    cmd: args,
    stdout: "inherit",
    stderr: "inherit",
  });
  
  await proc.status();
  proc.close();
}
