import $ from "./util.ts";

const WSA_PRODUCT_ID = "9P3395VX91NR";

async function fetchLink(productId: string) {
  const body = new FormData();
  body.append("type", "ProductId");
  body.append("ring", "WIS");
  body.append("url", productId);
  body.append("lang", "en-US");

  const data = await fetch("https://store.rg-adguard.net/api/GetFiles", {
    method: "POST",
    body,
  }).then(e => e.text());

  return data.match(/\<a href="(https?:\/\/tlu.dl.delivery.mp.microsoft.com\/filestreamingservice\/files\/[a-z0-9\-]+\?[a-zA-Z0-9 _%&=]+)" rel="noreferrer"\>MicrosoftCorporationII\.WindowsSubsystemForAndroid_[a-zA-Z0-9\._~]+\.msixbundle\<\/a\>/)![1];
}

if (!["x64", "arm64"].includes(Deno.args[0])) {
  console.error("Must specify x64 or arm64 arch in first argument");
  Deno.exit(0);
}

const exists = await Deno.lstat("./WSA.msixbundle").then(() => true).catch(() => {});

if (exists && !Deno.args.includes("-f")) {
  console.log("WSA.msixbundle already present, skipping download.");
} else {
  console.log("Fetching link...");
  const link = await fetchLink(WSA_PRODUCT_ID);

  console.log("Downloading...");
  await Deno.writeFile("./WSA.msixbundle", await fetch(link).then(e => e.arrayBuffer()).then(e => new Uint8Array(e)));
  console.log("Downloaded! Saved as WSA.msixbundle.");
}

console.log("Unzipping WSA (bundle)");
// Remove if already exists
await Deno.remove("./wsa", { recursive: true }).catch(() => {});
await $("unzip", "./WSA.msixbundle", "-d", "./wsa");

console.log("Unzipping WSA Package");
// Look for msix file matching given arch
const msix = [...Deno.readDirSync("./wsa")].find(({ name }) => name.endsWith(".msix") && name.toLowerCase().includes(Deno.args[0]))!.name;
// Remove if already exists
await Deno.remove("./wsa/wsapackage", { recursive: true }).catch(() => {});
await $("unzip", `./wsa/${msix}`, "-d", "./wsa/wsapackage");

console.log("Removing files from WSA Package");
await Deno.remove("./wsa/wsapackage/[Content_Types].xml");
await Deno.remove("./wsa/wsapackage/AppxBlockMap.xml");
await Deno.remove("./wsa/wsapackage/AppxSignature.p7x");

console.log("Copying Images...");
for await (const { name } of Deno.readDir("./wsa/wsapackage")) {
  if (!name.endsWith(".img")) continue;
  console.log("Copy", name);
  await Deno.copyFile(`./wsa/wsapackage/${name}`, `./#IMAGES/${name}`);
}
