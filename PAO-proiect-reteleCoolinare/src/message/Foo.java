package message;

import java.io.ObjectOutputStream;

public class Foo extends BaseMessage {
    public int coolValue = 0;

    public Foo(int coolValue) {
        this.coolValue = coolValue;
    }

    @Override
    public BaseMessage onNetworkMessage() {
        System.out.println("Mesaj receptionat :\t" + coolValue);
        return null;
    }

    @Override
    public void serialise(ObjectOutputStream out) throws java.io.IOException {
        out.writeObject(this);
    }

//    public int getCoolValue() {
//        return this.coolValue;
//    }
//
//    public void setCoolValue(int coolValue) {
//        this.coolValue = coolValue;
//    }
//
//    @Override
//    public String toString() {
//        return "Foo [coolValue=" + coolValue + "]";
//    }
}
