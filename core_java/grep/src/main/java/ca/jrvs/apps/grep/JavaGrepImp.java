package ca.jrvs.apps.grep;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class JavaGrepImp {

    private String regex;
    private String rootPath;
    private String outFile;

    public String getRegex() {
        return regex;
    }

    public void setRegex(String regex) {
        this.regex = regex;
    }

    public String getRootPath() {
        return rootPath;
    }

    public void setRootPath(String rootPath) {
    }

    public String getOutFile() {
        return "";
    }

    public void setOutFile(String outFile) {

    }

    public void process() throws IOException {

    }

    public List<File> listFiles(String rootDir) {
        List<File> filesList = new ArrayList<>();

        return filesList;
    }

    public List<String> readLines(File inputFile) {
        List<String> lines = new ArrayList<>();

        return lines;
    }

    public boolean containsPattern(String line) {
        return false;
    }

    public void writeToFile(List<String> lines) throws IOException {

    }

    public static void main(String[] args) {

    }
}
