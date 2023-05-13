import TurndownService from "turndown";

const turndownService = new TurndownService();

const htmlToMarkdown = (htmlContent) => turndownService.turndown(htmlContent);

const getEnv = (key) => process.env[key] || "";

export { htmlToMarkdown, getEnv };
