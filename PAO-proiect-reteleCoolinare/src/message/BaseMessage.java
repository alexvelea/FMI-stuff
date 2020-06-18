package message;

import java.io.ObjectOutputStream;
import java.io.Serializable;

public abstract class BaseMessage implements Serializable {
    abstract public BaseMessage onNetworkMessage() throws java.io.IOException;
    abstract public void serialise(ObjectOutputStream out) throws java.io.IOException;
}
