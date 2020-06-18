package message;

import java.io.ObjectInputStream;

public class MessageAgregator {
    static public BaseMessage onNetworkMessage(ObjectInputStream in) throws java.io.IOException, java.lang.ClassNotFoundException {
        Object o = in.readObject();

        if (o instanceof BaseMessage) {
            return ((BaseMessage)o).onNetworkMessage();
        }

        return null;
    }
}
