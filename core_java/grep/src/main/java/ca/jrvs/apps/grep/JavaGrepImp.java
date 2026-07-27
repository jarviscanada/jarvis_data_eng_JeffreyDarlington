package ca.jrvs.apps.grep;

import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

import org.apache.log4j.BasicConfigurator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class JavaGrepImp implements JavaGrep {

    private String regex;
    private String rootPath;
    private String outFile;
    private Pattern compiledPattern;
    private static final Logger logger = LoggerFactory.getLogger(JavaGrepImp.class);

    public void process() throws IOException {
        List<String> matchedLines = new ArrayList<>();
        for (File file: listFiles(getRootPath())) {
            for (String line: readLines(file)) {
                if(containsPattern(line)) {
                    matchedLines.add(line);
                }
            }
        }
        writeToFile(matchedLines); // ← add this
    }

    @Override
    public String getRegex() {
        return regex;
    }

    @Override
    public void setRegex(String regex) {
        this.regex = regex;
    }

    @Override
    public String getRootPath() {
        return rootPath;
    }

    @Override
    public void setRootPath(String rootPath) {
        this.rootPath = rootPath;
    }

    @Override
    public String getOutFile() {
        return outFile;
    }

    @Override
    public void setOutFile(String outFile) {
        this.outFile = outFile;
    }

    @Override
    public List<File> listFiles(String rootDir) {
        List<File> files = new ArrayList<>();
        File root = new File(rootDir);
        File[] children = root.listFiles();

        if(!root.exists() || !root.isDirectory()){
            logger.error("Invalid root directory: {}", rootDir);
            throw new IllegalArgumentException(
                    "Root directory does not exist or is not a directory: " + rootDir
            );
        }

        if (children == null) {
            logger.warn("Could not read directory (permissions?): {}", rootDir);
            return files;
        }

        for (File child : children) {
            if (child.isDirectory()) {
                files.addAll(listFiles(child.getAbsolutePath()));
            } else {
                files.add(child);
            }
        }
        return files;
    }

  @Override
  public List<String> readLines(File inputFile)  {
     List<String> lines = new ArrayList<>();
     try{
         BufferedReader br = new BufferedReader(new FileReader(inputFile));
         String line;

         while ((line = br.readLine()) != null){
             logger.warn("This lines are output: {}",line);
             lines.add(line);
         }
        br.close();
     } catch (IOException e) {
         logger.error("Failed to read file:{}", inputFile.getPath(), e);
     }
     return lines;
  }

    @Override
    public boolean containsPattern(String line) {
        if(compiledPattern == null){
            compiledPattern = Pattern.compile(getRegex());
        }
        return compiledPattern.matcher(line).find();
    }

    @Override
    public void writeToFile(List<String> matchedLines) throws IOException {
        File outputFile = new File(getOutFile());

        if (outputFile.getParentFile() != null) {
            outputFile.getParentFile().mkdirs();
        }

        try (BufferedWriter bufferedWriter = new BufferedWriter(
                new OutputStreamWriter(
                        new FileOutputStream(outputFile), "UTF-8"))) {
            for (String line : matchedLines) {
                bufferedWriter.write(line);
                bufferedWriter.newLine();
            }
        }
    }

    public static void main(String[] args) {
        BasicConfigurator.configure();
        if(args.length != 3){
            throw new IllegalArgumentException("USAGE: JavaGrep regex rootPath outFile");
        }
        JavaGrepImp app = new JavaGrepImp();
        app.setRegex(args[0]);
        app.setRootPath(args[1]);
        app.setOutFile(args[2]);
        logger.warn("args 1: {} {} {}",args[0],args[1],args[2]);
        try {
            app.process();
        } catch (IOException e) {
            logger.error("Failed to process grep", e);
        }
    }
}
