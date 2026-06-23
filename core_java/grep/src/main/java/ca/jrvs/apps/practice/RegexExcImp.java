package ca.jrvs.apps.practice;

public class RegexExcImp implements RegexExc {

    @Override
    public boolean matchJpeg(String jpeg) {
        return false;
    }

    @Override
    public boolean matchIp(String ip) {
        return false;
    }

    @Override
    public boolean matchUrl(String line) {
        return false;
    }
}
