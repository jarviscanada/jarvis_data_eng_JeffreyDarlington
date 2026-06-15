package ca.jrvs.apps.practice;

public interface RegexExc {
    /**
    * return true if filename extension is jpf or jpeg(case insensitive)
    * @param jpeg
    * @return
     */
    public boolean matchJpeg(String jpeg);

    /**
     * return true if ip is valid
     * to simplify the problem, IP address range is from 0.0.0.0 to 999.999.999.999
     * @param ip
     * @return
     */
    public boolean matchIp(String ip);

    /**
     * return true if line empty (e.g. empty, white space, tabs, etc...)
     * @param line
     * @return
     */
    public boolean matchUrl(String line);
}
